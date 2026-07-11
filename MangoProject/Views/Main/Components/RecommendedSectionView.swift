//  RecommendedSectionView.swift
//  MangoProject
//  Created by Muthiara Putri Aliyu on 09/07/26.
//
//

import SwiftUI

/// "Recommended For You" section: header + vertical list of full-width restaurant cards. Purely presentational — MainView supplies the data and bookmark action; this view has no knowledge of where either comes from.

struct RecommendedSectionView: View {
    let places: [RestaurantCardDisplayModel]
    var onBookmarkTapped: (RestaurantCardDisplayModel) -> Void = { _ in }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            Text("Recommended For You")
                .font(Typography.sectionHeader)
                .foregroundStyle(Color("TextPrimary"))

            VStack(spacing: Spacing.small) {
                ForEach(places) { place in
                    if let nearbyPlace = place.nearbyPlace {
                        NavigationLink(value: nearbyPlace) {
                            RestaurantCardView(
                                place: place,
                                onBookmarkTapped: { onBookmarkTapped(place) }
                            )
                        }
                        .buttonStyle(.plain)
                    } else {
                        RestaurantCardView(
                            place: place,
                            onBookmarkTapped: { onBookmarkTapped(place) }
                        )
                    }
                }
            }
        }
    }
}

#Preview {
    ScrollView {
        RecommendedSectionView(places: RestaurantCardDisplayModel.mockList)
            .padding()
    }
    .background(Color("AppBackground"))
}
