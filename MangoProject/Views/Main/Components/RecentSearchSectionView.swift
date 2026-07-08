//
//  RecentSearchSectionView.swift
//  MangoProject
//
//  Created by Muthiara Putri Aliyu on 09/07/26.

import SwiftUI

/// "Recently Searched" section: header + horizontal-scrolling list of
/// compact restaurant cards. Only shown when the user has search history —
/// MainView decides whether to include this view at all via
/// `viewModel.hasRecentSearches`.
struct RecentSearchSectionView: View {
    let places: [RestaurantCardDisplayModel]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            Text("Recently Searched")
                .font(Typography.sectionHeader)
                .foregroundStyle(Color("TextPrimary"))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.small) {
                    ForEach(places) { place in
                        RecentRestaurantCardView(place: place)
                    }
                }
                .padding(.horizontal, Spacing.medium)
            }
            .padding(.horizontal, -Spacing.medium)
        }
    }
}

#Preview {
    ScrollView {
        RecentSearchSectionView(places: RestaurantCardDisplayModel.mockList)
            .padding()
    }
    .background(Color("AppBackground"))
}
