//
//  MainMapViewModel.swift
//  MangoProject
//
//  Created by Belmiro Kayru on 05/07/26.
//

import Combine
import CoreLocation
import Foundation
import MapKit

final class MainMapViewModel: ObservableObject {
    @Published private(set) var places: [NearbyFoodPlace] = []
    @Published private(set) var isSearching = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var visibleRadiusText = "200 m"

    private var lastSearchCenter: CLLocation?
    private var lastSearchRadius: CLLocationDistance?

    private let csvPlaces: [CSVPlace] = CSVDataLoader.loadAll()

    #if DEBUG
    /// Testing aid only (stripped from release builds): a fake POI placed
    /// ~10m from wherever the user's location was when first available, so
    /// the walking-navigation distance readout can be tested by walking a
    /// short, real distance to a tappable pin instead of needing a real
    /// restaurant far away. Computed once and cached so it doesn't drift
    /// as the user moves.
    private var debugNearbyTestPlace: NearbyFoodPlace?
    #endif
    
    var datasetCategories: [String] {
        let halalPlaces = csvPlaces.filter { $0.halalFound && !$0.type.isEmpty }
        let uniqueTypes = Set(halalPlaces.map { $0.type.trimmingCharacters(in: .whitespacesAndNewlines) })
        return Array(uniqueTypes).sorted()
    }

    @MainActor
    func refreshPlaces(in region: MKCoordinateRegion, userLocation: CLLocation?) async {
        guard !isSearching else {
            return
        }

        let centerLocation = CLLocation(
            latitude: region.center.latitude,
            longitude: region.center.longitude
        )
        let visibleRadius = Self.visibleRadius(in: region)
        visibleRadiusText = Self.formattedDistance(visibleRadius)

        if shouldSkipSearch(center: centerLocation, radius: visibleRadius) {
            return
        }

        lastSearchCenter = centerLocation
        lastSearchRadius = visibleRadius
        isSearching = true
        errorMessage = nil

        var newPlaces: [NearbyFoodPlace] = []
        
        for csvPlace in self.csvPlaces where csvPlace.halalFound {
            let placeLocation = CLLocation(latitude: csvPlace.latitude, longitude: csvPlace.longitude)
            guard centerLocation.distance(from: placeLocation) <= visibleRadius else {
                continue
            }
            
            let coord = CLLocationCoordinate2D(latitude: csvPlace.latitude, longitude: csvPlace.longitude)
            let placemark = MKPlacemark(coordinate: coord)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = csvPlace.name
            
            let nearbyPlace = NearbyFoodPlace(mapItem: mapItem, userLocation: userLocation, csvPlace: csvPlace)
            newPlaces.append(nearbyPlace)
        }
        
        #if DEBUG
        if debugNearbyTestPlace == nil, let userLocation {
            debugNearbyTestPlace = Self.makeDebugNearbyTestPlace(near: userLocation.coordinate)
        }
        if let debugNearbyTestPlace {
            newPlaces.append(debugNearbyTestPlace)
        }
        #endif

        places = newPlaces
            .sorted { ($0.distanceInMeters ?? Double.greatestFiniteMagnitude) < ($1.distanceInMeters ?? Double.greatestFiniteMagnitude) }

        isSearching = false
    }

    @MainActor
    func openInMaps(_ place: NearbyFoodPlace) {
        place.mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking
        ])
    }
}

private extension MainMapViewModel {
    #if DEBUG
    /// Builds a fake, tappable POI ~10m north of `coordinate`. Flows through
    /// the exact same tap → card → Directions → Go pipeline as a real place,
    /// since it's just a normal `NearbyFoodPlace`.
    static func makeDebugNearbyTestPlace(near coordinate: CLLocationCoordinate2D) -> NearbyFoodPlace {
        let earthRadiusMeters = 6_371_000.0
        let angularDistance = 10.0 / earthRadiusMeters
        let latRadians = coordinate.latitude * .pi / 180

        let newLatRadians = latRadians + angularDistance
        let dummyCoordinate = CLLocationCoordinate2D(
            latitude: newLatRadians * 180 / .pi,
            longitude: coordinate.longitude
        )

        let placemark = MKPlacemark(coordinate: dummyCoordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "Test Spot (10m)"

        return NearbyFoodPlace(
            id: "debug-nearby-test-place",
            name: "Test Spot (10m)",
            address: "",
            category: "Test",
            coordinate: dummyCoordinate,
            phoneNumber: nil,
            url: nil,
            distanceInMeters: 10,
            mapItem: mapItem,
            businessName: nil,
            certificateNumber: nil,
            certificateIssueDate: nil,
            totalProducts: nil,
            isHalal: true
        )
    }
    #endif

    func shouldSkipSearch(center: CLLocation, radius: CLLocationDistance) -> Bool {
        guard let lastSearchCenter, let lastSearchRadius, !places.isEmpty else {
            return false
        }

        let centerDelta = center.distance(from: lastSearchCenter)
        let radiusDelta = abs(radius - lastSearchRadius)

        return centerDelta < 60 && radiusDelta < 50
    }

    func searchVisibleFoodPlaces(in region: MKCoordinateRegion) async -> [MKMapItem] {
        let poiItems = await searchFoodPOIs(in: region)

        guard poiItems.count < 6 else {
            return poiItems
        }

        let textQueries = [
            "restaurant",
            "restoran",
            "cafe",
            "coffee shop",
            "kedai kopi",
            "bakery",
            "toko roti",
            "dessert",
            "food court",
            "halal food"
        ]
        let textItems = await search(queries: textQueries, in: region)

        return poiItems + textItems
    }

    func searchFoodPOIs(in region: MKCoordinateRegion) async -> [MKMapItem] {
        let request = MKLocalPointsOfInterestRequest(coordinateRegion: region)
        request.pointOfInterestFilter = MKPointOfInterestFilter(including: [
            MKPointOfInterestCategory.restaurant,
            MKPointOfInterestCategory.cafe,
            MKPointOfInterestCategory.bakery
        ])

        do {
            return try await MKLocalSearch(request: request).start().mapItems
        } catch {
            errorMessage = "Could not load nearby places. Please try again."
            return []
        }
    }

    func search(queries: [String], in region: MKCoordinateRegion) async -> [MKMapItem] {
        await withTaskGroup(of: [MKMapItem].self) { group in
            for query in queries {
                group.addTask {
                    await Self.search(query: query, in: region)
                }
            }

            var mapItems: [MKMapItem] = []

            for await result in group {
                mapItems.append(contentsOf: result)
            }

            return mapItems
        }
    }

    static func search(query: String, in region: MKCoordinateRegion) async -> [MKMapItem] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = MKLocalSearch.ResultType.pointOfInterest
        request.region = region

        do {
            return try await MKLocalSearch(request: request).start().mapItems
        } catch {
            return []
        }
    }

    func isAllowedFoodPlace(_ mapItem: MKMapItem) -> Bool {
        let blockedCategoryRawValues: Set<String> = [
            "MKPOICategoryFoodMarket"
        ]
        let blockedNameKeywords = [
            "supermarket",
            "grocery",
            "minimarket",
            "alfamart",
            "indomaret",
            "hypermart",
            "ranch market",
            "farmers market"
        ]
        let foodNameKeywords = [
            "ayam",
            "bakery",
            "bakmi",
            "bakso",
            "bento",
            "bread",
            "burger",
            "cake",
            "cafe",
            "coffee",
            "croissant",
            "dessert",
            "donut",
            "food",
            "fried chicken",
            "kebab",
            "kedai kopi",
            "kopi",
            "latte",
            "matcha",
            "mie",
            "noodle",
            "pastry",
            "patisserie",
            "pizza",
            "ramen",
            "restaurant",
            "restoran",
            "rice",
            "roti",
            "sate",
            "sushi",
            "tea"
        ]
        let searchableText = [
            mapItem.name
        ]
            .compactMap { $0?.lowercased() }
            .joined(separator: " ")
        let searchableTokens = Set(
            searchableText
                .components(separatedBy: CharacterSet.alphanumerics.inverted)
                .filter { !$0.isEmpty }
        )

        if let categoryRawValue = mapItem.pointOfInterestCategory?.rawValue,
           blockedCategoryRawValues.contains(categoryRawValue) {
            return false
        }

        if blockedNameKeywords.contains(where: { searchableText.contains($0) }) {
            return false
        }

        if searchableTokens.contains("market") || searchableTokens.contains("mart") {
            return false
        }

        if mapItem.pointOfInterestCategory?.rawValue == "MKPOICategoryStore" {
            return foodNameKeywords.contains { searchableText.contains($0) }
        }

        return true
    }

    static func visibleRadius(in region: MKCoordinateRegion) -> CLLocationDistance {
        let center = CLLocation(latitude: region.center.latitude, longitude: region.center.longitude)
        let northEdge = CLLocation(
            latitude: region.center.latitude + region.span.latitudeDelta / 2,
            longitude: region.center.longitude
        )
        let eastEdge = CLLocation(
            latitude: region.center.latitude,
            longitude: region.center.longitude + region.span.longitudeDelta / 2
        )

        return max(center.distance(from: northEdge), center.distance(from: eastEdge))
    }

    static func itemID(for item: MKMapItem) -> String {
        let coordinate: CLLocationCoordinate2D
        if #available(iOS 26, *) {
            coordinate = item.location.coordinate
        } else {
            coordinate = item.placemark.coordinate
        }

        return [
            item.name ?? "Unknown",
            String(format: "%.6f", coordinate.latitude),
            String(format: "%.6f", coordinate.longitude)
        ].joined(separator: "-")
    }

    static func formattedDistance(_ meters: CLLocationDistance) -> String {
        if meters >= 1_000 {
            return String(format: "%.1f km", meters / 1_000)
        }

        return "\(Int(meters.rounded())) m"
    }
}
