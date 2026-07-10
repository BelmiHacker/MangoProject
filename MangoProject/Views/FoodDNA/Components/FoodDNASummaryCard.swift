//
//   FoodDNASummaryCard.swift
//  MangoProject
//
//  Created by Muthiara Putri Aliyu on 10/07/26.
//
//

import SwiftUI

/// Top summary card on the Food DNA screen — icon, status title, description,
/// and a decorative colored circle. Color/copy/icon all driven by the
/// overall DishDNAStatus passed in; this view has no logic of its own.
struct FoodDNASummaryCard: View {
    let status: DishDNAStatus

    var body: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(darkColor)
                .frame(width: 6)

            VStack(alignment: .leading, spacing: Spacing.small) {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: status.iconName)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 28, height: 28)
                        .background(darkColor)
                        .clipShape(Circle())

                    Text(status.summaryTitle)
                        .font(Typography.cardTitle)
                        .foregroundStyle(darkColor)
                }

                Text(status.summaryDescription)
                    .font(Typography.bodySecondary)
                    .foregroundStyle(Color("TextPrimary").opacity(0.75))
            }
            .padding(Spacing.cardPadding)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(lightColor)
        .clipShape(RoundedRectangle(cornerRadius: Radius.card))
        .appShadow(Shadow.card)
    }

    private var darkColor: Color {
        switch status {
        case .halal: return Color("StatusHalalDark")
        case .needsVerification: return Color("StatusWarningDark")
        case .nonHalal: return Color("StatusDangerDark")
        }
    }

    private var lightColor: Color {
        switch status {
        case .halal: return Color("StatusHalalLight")
        case .needsVerification: return Color("StatusWarningLight")
        case .nonHalal: return Color("StatusDangerLight")
        }
    }
}

#Preview {
    VStack(spacing: Spacing.medium) {
        FoodDNASummaryCard(status: .halal)
        FoodDNASummaryCard(status: .needsVerification)
        FoodDNASummaryCard(status: .nonHalal)
    }
    .padding()
    .background(Color("AppBackground"))
}
