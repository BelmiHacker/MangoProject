//
//  ExploreSheetContent.swift
//  MangoProject
//

import SwiftUI

struct ExploreSheetContent: View {

    @Binding var searchText: String
    @Binding var selectedCategory: String
    let categories: [String]
    let places: [NearbyFoodPlace]
    let isSearching: Bool
    let onSelectCategory: (String) -> Void
    let onClearSearch: () -> Void
    let onDirections: (NearbyFoodPlace) -> Void

    var body: some View {
        VStack(spacing: 0) {
            ExploreSearchBar(text: $searchText, onClear: onClearSearch)
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 10)

            Divider()

            ExplorePlacesList(
                places: places,
                isSearching: isSearching,
                searchText: searchText,
                onDirections: onDirections
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .background {
            if #available(iOS 26, *) {
                Color.clear
                    .glassEffect(in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            } else {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(.ultraThinMaterial)
            }
        }
    }
}
