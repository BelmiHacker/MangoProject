//
//  ConcernRow.swift
//  MangoProject
//
//  Created by Muthiara Putri Aliyu on 10/07/26.
//


import SwiftUI

/// A single "potential concern" line item, e.g. "Bacon type is unclear"
/// or "Pork bacon is not halal". Icon and color driven by the dish's
/// status — amber warning triangle for needsVerification, red X for nonHalal.
struct ConcernRow: View {
    let text: String
    let status: DishDNAStatus

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.xs) {
            Image(systemName: iconName)
                .foregroundStyle(color)
                .font(.system(size: 14, weight: .bold))

            Text(text)
                .font(Typography.cardSubtitle)
                .foregroundStyle(Color("TextPrimary"))
        }
    }

    private var iconName: String {
        switch status {
        case .needsVerification: return "exclamationmark.triangle.fill"
        case .nonHalal: return "xmark.circle.fill"
        case .halal: return "checkmark.circle.fill"
        }
    }

    private var color: Color {
        switch status {
        case .needsVerification: return Color("StatusWarningDark")
        case .nonHalal: return Color("StatusDangerDark")
        case .halal: return Color("StatusHalalDark")
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: Spacing.small) {
        ConcernRow(text: "Bacon type is unclear (Pork or beef?)", status: .needsVerification)
        ConcernRow(text: "Pork bacon is not halal", status: .nonHalal)
    }
    .padding()
    .background(Color("AppBackground"))
}
