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

        var mapItemsByID: [String: MKMapItem] = [:]

        let mapItems = await searchVisibleFoodPlaces(in: region)

        for item in mapItems {
            let coordinate = item.placemark.coordinate
            let itemLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

            guard centerLocation.distance(from: itemLocation) <= visibleRadius else {
                continue
            }

            let id = Self.itemID(for: item)
            mapItemsByID[id] = item
        }

        places = mapItemsByID.values
            .filter(isAllowedFoodPlace)
            .map { NearbyFoodPlace(mapItem: $0, userLocation: userLocation) }
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
            mapItem.name,
            mapItem.placemark.title
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
        let coordinate = item.placemark.coordinate

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
