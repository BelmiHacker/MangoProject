//
//  ExploreSheetContent.swift
//  MangoProject
//

import SwiftUI

struct ExploreSheetContent: View {

    @Binding var searchText: String
    @Binding var selectedCategories: Set<String>
    let categories: [String]
    let places: [NearbyFoodPlace]
    let isSearching: Bool
    let onSelectCategory: (String) -> Void
    let onClearSearch: () -> Void
    let onDirections: (NearbyFoodPlace) -> Void
    let onSelect: (NearbyFoodPlace) -> Void

    var body: some View {
        VStack(spacing: 0) {
            ExploreSearchBar(text: $searchText, onClear: onClearSearch)
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 10)

            ExploreCategoryChips(
                categories: categories,
                selectedCategories: selectedCategories,
                onSelect: onSelectCategory
            )
            .padding(.bottom, 12)

            Divider()

            ExplorePlacesList(
                places: places,
                isSearching: isSearching,
                searchText: searchText,
                onDirections: onDirections,
                onSelect: onSelect
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
