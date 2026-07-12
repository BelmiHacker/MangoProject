//
//  RestaurantCardView.swift
//  MangoProject
//
//  Created by Muthiara Putri Aliyu on 09/07/26.
//


import SwiftUI

/// Full-width restaurant card used in "Recommended For You" and similar sections.
/// Purely presentational — takes a display model and an action closure in,
/// contains no data-fetching or persistence logic.
struct RestaurantCardView: View {
    let place: RestaurantCardDisplayModel
    var onBookmarkTapped: () -> Void = {}

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.small) {
            imageThumbnail

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                HStack(alignment: .top) {
                    Text(place.name)
                        .font(Typography.cardTitle)
                        .foregroundStyle(Color("TextPrimary"))
                        .lineLimit(1)

                    Spacer()

                    bookmarkButton
                }

                HStack(spacing: Spacing.xxs) {
                    Text(place.categoryDisplayName)
                    Text("-")
                    Text(place.distanceText)

                    Image(systemName: "star.fill")
                        .foregroundStyle(Color("AccentStar"))
                        .padding(.leading, Spacing.xxs)

                    Text(String(format: "%.1f", place.rating))
                }
                .font(Typography.cardSubtitle)
                .foregroundStyle(Color("TextSecondary"))

                Text(place.descriptionText)
                    .font(Typography.bodySecondary)
                    .foregroundStyle(Color("TextSecondary"))
                    .lineLimit(2)

                HStack(spacing: Spacing.xxs) {
                    Image(systemName: "mappin")
                    Text(place.addressText)
                }
                .font(Typography.caption)
                .foregroundStyle(Color("TextSecondary"))
            }
        }
        .padding(Spacing.cardPadding)
        .background(Color("CardBackground"))
        .clipShape(RoundedRectangle(cornerRadius: Radius.card))
        .appShadow(Shadow.card)
    }

    private var imageThumbnail: some View {
        RestaurantPhotoView(name: place.name, category: place.categoryDisplayName)
            .frame(width: 88, height: 88)
            .clipShape(RoundedRectangle(cornerRadius: Radius.small))
    }

    private var bookmarkButton: some View {
        Button(action: onBookmarkTapped) {
            Image(systemName: place.isBookmarked ? "bookmark.fill" : "bookmark")
                .foregroundStyle(Color("TextPrimary"))
        }
        .accessibilityLabel(place.isBookmarked ? "Remove bookmark" : "Add bookmark")
    }
}

#Preview {
    VStack(spacing: Spacing.small) {
        RestaurantCardView(place: RestaurantCardDisplayModel.mockList[0])
        RestaurantCardView(place: RestaurantCardDisplayModel.mockList[1])
    }
    .padding()
    .background(Color("AppBackground"))
}
