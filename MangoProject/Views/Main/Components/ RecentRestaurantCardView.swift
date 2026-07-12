//  RecentRestaurantCardView.swift
//  MangoProject
//
//  Created by Muthiara Putri Aliyu on 09/07/26.
//  Views/Main/Components
//

import SwiftUI

/// Compact restaurant card used in horizontal-scrolling sections,
/// e.g. "Recently Searched". Purely presentational — no bookmark
/// or address shown here, matching the condensed layout in the mockup.
struct RecentRestaurantCardView: View {
    let place: RestaurantCardDisplayModel

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            imageThumbnail

            Text(place.name)
                .font(Typography.cardTitle)
                .foregroundStyle(Color("TextPrimary"))
                .lineLimit(1)

            HStack(spacing: Spacing.xxs) {
                Text(place.categoryDisplayName)
                Text("-")
                Text(place.distanceText)
            }
            .font(Typography.cardSubtitle)
            .foregroundStyle(Color("TextSecondary"))
            .lineLimit(1)

            HStack(spacing: Spacing.xxs) {
                Image(systemName: "star.fill")
                    .foregroundStyle(Color("AccentStar"))
                Text(String(format: "%.1f", place.rating))
                    .foregroundStyle(Color("TextSecondary"))
            }
            .font(Typography.caption)
        }
        .padding(Spacing.small)
        .frame(width: 168, alignment: .leading)
        .background(Color("CardBackground"))
        .clipShape(RoundedRectangle(cornerRadius: Radius.card))
        .appShadow(Shadow.card)
    }

    private var imageThumbnail: some View {
        RestaurantPhotoView(name: place.name, category: place.categoryDisplayName)
            .frame(height: 100)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: Radius.small))
    }
}

#Preview {
    ScrollView(.horizontal) {
        HStack(spacing: Spacing.small) {
            ForEach(RestaurantCardDisplayModel.mockList) { place in
                RecentRestaurantCardView(place: place)
            }
        }
        .padding()
    }
    .background(Color("AppBackground"))
}
