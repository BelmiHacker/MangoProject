//
//  PointsCardView.swift
//  MangoProject
//
//  Created by Muthiara Putri Aliyu on 09/07/26.
//

import SwiftUI

/// The "My Points" banner shown near the top of MainView.
/// Purely presentational — the points value is passed in, not computed here.
/// Will later reflect real-time updates after NFC scans via MainViewModel.
struct PointsCardView: View {
    let points: Int

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("My Points")
                    .font(Typography.cardSubtitle)
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

            // Placeholder badge — mockup shows a plain circular element here.
            // Exact purpose (avatar? tier icon?) to be confirmed with design.
            Circle()
                .fill(.white)
                .frame(width: 44, height: 44)
        }
        .padding(Spacing.cardPadding)
        .background(Color("Accent"))
        .clipShape(RoundedRectangle(cornerRadius: Radius.card))
        .appShadow(Shadow.card)
    }
}

#Preview {
    PointsCardView(points: 67)
        .padding()
        .background(Color("AppBackground"))
}
