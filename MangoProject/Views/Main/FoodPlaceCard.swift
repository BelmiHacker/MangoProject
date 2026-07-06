//
//  FoodPlaceCard.swift
//  MangoProject
//
//  Created by Belmiro Kayru on 05/07/26.
//

import SwiftUI

// MARK: - Place Card

struct FoodPlaceCard: View {
    let place: NearbyFoodPlace
    let isFocused: Bool
    let onFocus: () -> Void
    let onNavigate: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: 14) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(place.name)
                        .font(.system(size: 29, weight: .bold))
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.75)

                    Text(place.address.isEmpty ? place.category : place.address)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                }

                Spacer()

                Image(systemName: "fork.knife")
                    .font(.system(size: 25, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 58, height: 58)
                    .background(isFocused ? Color(.systemOrange) : Color(.systemGreen))
                    .clipShape(Circle())
            }

            HStack(spacing: 14) {
                MetricPill(systemImage: "figure.walk", text: place.distanceText)
                MetricPill(systemImage: "fork.knife", text: place.category)
            }

            HStack(spacing: 12) {
                Button(action: onNavigate) {
                    HStack {
                        Text("Start finding")
                        Spacer()
                        Image(systemName: "arrow.up.right")
                    }
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color(.systemBackground))
                    .padding(.horizontal, 18)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color(.label))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .buttonStyle(.plain)

                Button {
                } label: {
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.primary)
                    .frame(width: 56, height: 56)
                    .background(Color(.tertiarySystemFill))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(22)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(isFocused ? Color(.systemOrange) : Color.clear, lineWidth: 3)
        )
        .shadow(color: .black.opacity(isFocused ? 0.16 : 0.08), radius: isFocused ? 20 : 12, y: 8)
        .scaleEffect(isFocused ? 1.01 : 1)
        .contentShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .onTapGesture {
            onFocus()
        }
        .animation(.snappy, value: isFocused)
    }
}

// MARK: - Metrics

struct MetricPill: View {
    let systemImage: String
    let text: String

    var body: some View {
        Label(text, systemImage: systemImage)
            .font(.system(size: 16, weight: .bold))
            .foregroundStyle(.primary)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .padding(.horizontal, 14)
            .frame(height: 44)
            .background(Color(.tertiarySystemFill))
            .clipShape(Capsule())
    }
}
