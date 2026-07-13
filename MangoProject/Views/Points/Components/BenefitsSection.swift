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

    static let samples: [Benefit] = [
        .init(id: 0, title: "Free Coffee", subtitle: "Any halal cafe", icon: "cup.and.saucer.fill", pointsCost: 30),
        .init(id: 1, title: "10% Off", subtitle: "At any halal resto", icon: "cart.fill", pointsCost: 60),
        .init(id: 2, title: "Free Dessert", subtitle: "Free dessert at halal resto", icon: "birthday.cake.fill", pointsCost: 120),
    ]
}

struct BenefitsSection: View {
    let benefits: [Benefit]
    let points: Int
    var onRedeem: (Benefit) -> Void = { _ in }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Benefits")
                .font(Typography.sectionHeader)
                .foregroundStyle(Color(.textPrimary))

            HStack(spacing: 10) {
                ForEach(benefits) { benefit in
                    BenefitCard(
                        benefit: benefit,
                        isUnlocked: points >= benefit.pointsCost,
                        onRedeem: { onRedeem(benefit) }
                    )
                }
            }
        }
    }
}

private struct BenefitCard: View {
    let benefit: Benefit
    let isUnlocked: Bool
    var onRedeem: () -> Void = {}
    private let cardColor = Color("Accent")

    var body: some View {
        Button(action: onRedeem) {
            VStack(spacing: 0) {
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.18))
                            .frame(width: 52, height: 52)
                        Image(systemName: benefit.icon)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(.white)

                        if !isUnlocked {
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
                .background(cardColor.opacity(isUnlocked ? 1.0 : 0.72))

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(.yellow)
                    Text("\(benefit.pointsCost)")
                        .font(Typography.sectionHeader)
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 30)
                .background(cardColor.opacity(isUnlocked ? 0.65 : 0.45))
            }
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(NoDimmingButtonStyle())
        .disabled(!isUnlocked)
    }
}

/// `.disabled()` combined with `.buttonStyle(.plain)` still applies SwiftUI's
/// automatic dimming to the whole label, which washed out the manually-drawn
/// lock badge on locked cards. This style ignores `isEnabled` entirely so the
/// locked appearance is controlled solely by `BenefitCard`'s own opacity/lock
/// overlay, while `.disabled()` still correctly blocks taps and marks the
/// card unavailable to VoiceOver.
private struct NoDimmingButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

