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
                .fill(status.accentColor)
                .frame(width: 6)

            VStack(alignment: .leading, spacing: Spacing.small) {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: status.iconName)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 28, height: 28)
                        .background(status.accentColor)
                        .clipShape(Circle())

                    Text(status.summaryTitle)
                        .font(Typography.cardTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(status.accentColor)
                }

                Text(status.summaryDescription)
                    .font(Typography.bodySecondary)
                    .foregroundStyle(Color("DishBodyText"))
            }
            .padding(Spacing.cardPadding)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(status.expandedBackground)
        .overlay {
            RoundedRectangle(cornerRadius: Radius.dishCard)
                .stroke(status.cardBorder, lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: Radius.dishCard))
        .appShadow(Shadow.card)
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
