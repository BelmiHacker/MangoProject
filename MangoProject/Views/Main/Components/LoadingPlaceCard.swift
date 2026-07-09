//
//  LoadingPlaceCard.swift
//  MangoProject
//

import SwiftUI

struct LoadingPlaceCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 8) {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(Color(.systemGray4))
                        .frame(width: 160, height: 20)
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(Color(.systemGray5))
                        .frame(width: 120, height: 14)
                }
                Spacer()
                Circle()
                    .fill(Color(.systemGray5))
                    .frame(width: 58, height: 58)
            }

            HStack(spacing: 14) {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color(.systemGray5))
                    .frame(width: 100, height: 44)
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color(.systemGray5))
                    .frame(width: 100, height: 44)
            }

            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.systemGray4))
                .frame(height: 56)
        }
        .padding(22)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .shimmer()
    }
}

// MARK: - Shimmer Modifier

private struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [
                        .clear,
                        Color.white.opacity(0.2),
                        .clear
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .offset(x: phase)
                .animation(
                    .linear(duration: 1.5).repeatForever(autoreverses: false),
                    value: phase
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .onAppear {
                phase = 400
            }
    }
}

private extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}
