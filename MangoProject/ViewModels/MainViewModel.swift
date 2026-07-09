//
//  MainViewModel.swift
//  MangoProject
//
//  Created by Muthiara Putri Aliyu on 09/07/26.
//

import Foundation

/// Owns the state for MainView.
/// Currently populated with mock/placeholder data — no networking, no persistence.
///
/// This is the seam where future business logic connects:
/// - `userPoints` will later update after NFC scans (via a PointsService or similar)
/// - `recommendedPlaces` will later be populated by an API/database call
/// - `recentSearches` will later be populated from user search history
/// - `userName` will later come from a real `UserProfile`
///
/// Views stay "dumb" — they only read these published properties and
/// call the exposed methods; they never contain this logic themselves.
@Observable
final class MainViewModel {

    // MARK: - Greeting

    /// Placeholder until UserProfile is wired in.
    var userName: String = "Muthi"

    // MARK: - Points

    /// Placeholder until UserProfile gains a `points` field (or equivalent),
    /// updated later via NFC scan logic.
    var userPoints: Int = 67

    // MARK: - Restaurant sections

    var recommendedPlaces: [RestaurantCardDisplayModel] = RestaurantCardDisplayModel.mockList

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
