//
//  ExplorePlaceCard.swift
//  MangoProject
//

import SwiftUI

struct ExplorePlaceCard: View {
    let place: NearbyFoodPlace
    var onClose: () -> Void
    var onDirections: () -> Void

    @State private var selectedPhoto: SelectedPhoto?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            placeHeader
            directionsButton
            photoStrip
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity)
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
        .fullScreenCover(item: $selectedPhoto) { photo in
            ExplorePhotoViewer(photo: photo) {
                selectedPhoto = nil
            }
        }
    }
}

private extension ExplorePlaceCard {
    var placeHeader: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 5) {
                Text(place.name)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                HStack(spacing: 4) {
                    Text(place.category)
                    Text("·")
                    Text(place.distanceText)
                }
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(.secondary)

                HStack(spacing: 4) {
                    Text("Open")
                        .foregroundStyle(.green)
                    Text("·")
                        .foregroundStyle(.secondary)
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                    Text("4.2")
                        .foregroundStyle(.primary)
                }
                .font(.system(size: 14, weight: .semibold))
            }

            Spacer()

            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.secondary)
                    .frame(width: 28, height: 28)
                    .background(Color.primary.opacity(0.1))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
    }

    var directionsButton: some View {
        Button(action: onDirections) {
            HStack(spacing: 8) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 14, weight: .semibold))
                Text("Directions")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 46)
            .background(Color.green)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    var photoStrip: some View {
        let images = RestaurantPhotoAsset.availableImages(for: place.name)

        return HStack(spacing: 8) {
            if images.isEmpty {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.primary.opacity(0.08))
                    .frame(height: 68)
                    .frame(maxWidth: .infinity)
                    .overlay(
                        Image(systemName: RestaurantPhotoAsset.categoryIcon(for: place.category))
                            .font(.system(size: 18))
                            .foregroundStyle(.tertiary)
                    )
            } else {
                ForEach(Array(images.prefix(4).enumerated()), id: \.offset) { index, uiImage in
                    Button {
                        selectedPhoto = SelectedPhoto(image: uiImage)
                    } label: {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 68)
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Photo \(index + 1) of \(place.name)")
                }
            }
        }
    }
}
