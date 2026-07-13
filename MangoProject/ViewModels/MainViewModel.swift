//
//  MainViewModel.swift
//  MangoProject
//
//  Created by Muthiara Putri Aliyu on 09/07/26.
//

import Foundation
import CoreLocation
import MapKit

/// Owns the state for MainView.
/// Currently populated with mock/placeholder data — no networking, no persistence.
///
/// This is the seam where future business logic connects:
/// - `recommendedPlaces` will later be populated by an API/database call
/// - `recentSearches` will later be populated from user search history
/// - `userName` will later come from a real `UserProfile`
///
/// Views stay "dumb" — they only read these published properties and
/// call the exposed methods; they never contain this logic themselves.
///
/// Points are intentionally NOT owned here — they live in `UserPointsStore`,
/// shared across the Home and Points tabs, so a single instance is the
/// source of truth instead of each screen keeping its own counter.
@Observable
final class MainViewModel {

    // MARK: - Greeting

    /// Placeholder until UserProfile is wired in.
    var userName: String = "Muthi"

    // MARK: - Restaurant sections

    var recommendedPlaces: [RestaurantCardDisplayModel] = {
        let allPlaces = CSVDataLoader.loadAll().filter { $0.halalFound }
        var mapped = allPlaces.map { csv in
            let hash = abs(csv.name.hashValue)
            let rating = 3.0 + Double(hash % 21) / 10.0
            let coordinate = CLLocationCoordinate2D(latitude: csv.latitude, longitude: csv.longitude)
            let placemark = MKPlacemark(coordinate: coordinate)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = csv.name
            let nearbyPlace = NearbyFoodPlace(mapItem: mapItem, userLocation: nil, csvPlace: csv)
            
            return RestaurantCardDisplayModel(
                id: csv.name,
                name: csv.name,
                categoryDisplayName: csv.type.isEmpty ? "Food" : csv.type,
                distanceText: "Nearby",
                rating: rating,
                descriptionText: csv.businessName,
                addressText: "The Breeze / Maggiore",
                isBookmarked: false,
                imagePlaceholderSymbol: "photo",
                nearbyPlace: nearbyPlace
            )
        }
        mapped.sort { $0.rating > $1.rating }
        return mapped
    }()

    /// Empty by default to represent a first-time user with no search history yet.
    /// Populate with mock data manually while testing the "after use" state.
    var recentSearches: [RestaurantCardDisplayModel] = []

    // MARK: - Derived state

    /// Drives whether MainView shows the "Recently Searched" section at all.
    var hasRecentSearches: Bool {
        !recentSearches.isEmpty
    }

    // MARK: - Actions (no-op placeholders for now)

    /// Will later persist bookmark state via a service/backend call.
    func toggleBookmark(for place: RestaurantCardDisplayModel) {
        // Intentionally left as a no-op — UI-only phase.
        // Future: call a BookmarkService, then update local state or refetch.
    }
}
