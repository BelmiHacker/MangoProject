//
//  ExplorePlacesList.swift
//  MangoProject
//

import SwiftUI

struct ExplorePlacesList: View {

    let places: [NearbyFoodPlace]
    let isSearching: Bool
    let searchText: String
    let onDirections: (NearbyFoodPlace) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 12) {
                if searchText.isEmpty {
                    Text("Nearby restaurant")
                        .font(.headline)
                        .padding(.horizontal, 16)
                        .padding(.top, 14)
                        .padding(.bottom, 2)
                }

                if isSearching && places.isEmpty {
                    ForEach(0..<3, id: \.self) { _ in
                        ExploreCardSkeleton()
                            .padding(.horizontal, 16)
                    }
                } else if places.isEmpty {
                    Text(
                        searchText.isEmpty
                            ? "No halal food found nearby."
                            : "No results for \"\(searchText)\"."
                    )
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                } else {
                    ForEach(places.prefix(20)) { place in
                        ExploreRestaurantCard(place: place) {
                            onDirections(place)
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
            .padding(.bottom, 48)
        }
    }
}
