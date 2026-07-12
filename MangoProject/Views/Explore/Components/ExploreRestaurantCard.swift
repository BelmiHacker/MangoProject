//
//  ExploreRestaurantCard.swift
//  MangoProject
//

import SwiftUI

struct ExploreRestaurantCard: View {

    let place: NearbyFoodPlace
    let onDirections: () -> Void
    let onSelect: () -> Void

    private let accent = Color(red: 0.18, green: 0.42, blue: 0.35)

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                placeInfo
                Spacer()
                directionsButton
            }
            photoStrip
        }
        .padding(16)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .background {
            if #available(iOS 26, *) {
                Color.clear
                    .glassEffect(in: RoundedRectangle(cornerRadius: 16))
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.regularMaterial)
            }
        }
        .onTapGesture {
            onSelect()
        }
    }

    private var placeInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(place.name)
                .font(.headline)
                .lineLimit(1)
            Text("\(place.category) · \(place.distanceText)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            HStack(spacing: 4) {
                Text("Open")
                Image(systemName: "star.fill")
                    .font(.caption)
                    .foregroundStyle(.yellow)
                Text("4.2")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
    }

    private var directionsButton: some View {
        Button(action: onDirections) {
            Label("Directions", systemImage: "paperplane.fill")
                .font(.subheadline.bold())
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(accent)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private var photoStrip: some View {
        RestaurantPhotoView(name: place.name, category: place.category)
            .frame(height: 96)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
