//
//  BenefitsSection.swift
//  MangoProject
//

import SwiftUI

struct Benefit: Identifiable {
    let id: Int
    let title: String
    let subtitle: String
    let icon: String
    let pointsCost: Int
    let isUnlocked: Bool

    static let samples: [Benefit] = [
        .init(id: 0, title: "Free Coffee", subtitle: "Any halal cafe", icon: "cup.and.saucer.fill", pointsCost: 30, isUnlocked: true),
        .init(id: 1, title: "10% Off", subtitle: "At any halal resto", icon: "cart.fill", pointsCost: 60, isUnlocked: true),
        .init(id: 2, title: "Free Dessert", subtitle: "Free dessert at halal resto", icon: "birthday.cake.fill", pointsCost: 120, isUnlocked: false),
    ]
}

private let tierColors: [Color] = [
    Color(red: 0.24, green: 0.58, blue: 0.43),  // Free Coffee — medium green
    Color(red: 0.13, green: 0.42, blue: 0.31),  // 10% Off — rich green
    Color(red: 0.05, green: 0.24, blue: 0.18),  // Free Dessert — deep forest green
]

struct BenefitsSection: View {
    let benefits: [Benefit]
    var onRedeem: (Benefit) -> Void = { _ in }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Benefits")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.primary)

            HStack(spacing: 10) {
                ForEach(Array(benefits.enumerated()), id: \.element.id) { index, benefit in
                    BenefitCard(
                        benefit: benefit,
                        cardColor: tierColors[min(index, tierColors.count - 1)],
                        onRedeem: { onRedeem(benefit) }
                    )
                }
            }
        }
    }
}

private struct BenefitCard: View {
    let benefit: Benefit
    let cardColor: Color
    var onRedeem: () -> Void = {}

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.18))
                        .frame(width: 52, height: 52)
                    Image(systemName: benefit.icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white)

                    if !benefit.isUnlocked {
                        Circle()
                            .fill(.black.opacity(0.28))
                            .frame(width: 52, height: 52)
                        Image(systemName: "lock.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white.opacity(0.85))
                    }
                }

                Text(benefit.title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text(benefit.subtitle)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(.white.opacity(0.72))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, minHeight: 130)
            .padding(.horizontal, 8)
            .padding(.top, 16)
            .padding(.bottom, 12)
            .background(cardColor.opacity(benefit.isUnlocked ? 1.0 : 0.72))

            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.system(size: 11))
                    .foregroundStyle(.yellow)
                Text("\(benefit.pointsCost)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 30)
            .background(cardColor.opacity(benefit.isUnlocked ? 0.65 : 0.45))
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .onTapGesture { onRedeem() }
    }
}
