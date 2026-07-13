//
//  PointsSummaryCard.swift
//  MangoProject
//

import SwiftUI

/// The "My Points" banner — shared between MainView (Home) and PointsPageView
/// so the card renders at the same size/position on both screens instead of
/// each screen keeping its own copy that could drift apart.
struct PointsSummaryCard: View {
    let points: Int
    var onTapToCollect: () -> Void = {}

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("My Points")
                    .font(Typography.sectionHeader)
                    .foregroundStyle(.white.opacity(0.85))

                HStack(spacing: Spacing.xxs) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(Color("AccentStar"))

                    Text("\(points)")
                        .font(Typography.screenTitle)
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())
                }
            }

            Spacer()

            Button(action: onTapToCollect) {
                HStack(spacing: 6) {
                    Image(systemName: "wave.3.right")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Tap To Collect")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundStyle(Color(red: 0.11, green: 0.38, blue: 0.29))
                .padding(.horizontal, 16)
                .frame(height: 40)
                .background(.white)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(Spacing.cardPadding)
        .background(Color("Accent"))
        .clipShape(RoundedRectangle(cornerRadius: Radius.card))
        .appShadow(Shadow.card)
    }
}

#Preview {
    PointsSummaryCard(points: 67)
        .padding()
        .background(Color("AppBackground"))
}
