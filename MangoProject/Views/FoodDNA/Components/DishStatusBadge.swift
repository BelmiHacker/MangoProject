//
//  DishStatusBadge.swift
//  MangoProject
//

import SwiftUI

/// Small pill shown under a dish name, e.g. "Likely Halal". Purely
/// presentational — color and copy come from `DishDNAStatus`.
struct DishStatusBadge: View {
    let status: DishDNAStatus

    var body: some View {
        Text(status.badgeLabel)
            .font(Typography.caption)
            .foregroundStyle(status.badgeText)
            .padding(.horizontal, Spacing.small)
            .padding(.vertical, Spacing.xxs)
            .background(status.badgeBackground)
            .clipShape(Capsule())
    }
}

#Preview {
    VStack(alignment: .leading, spacing: Spacing.small) {
        DishStatusBadge(status: .halal)
        DishStatusBadge(status: .needsVerification)
        DishStatusBadge(status: .nonHalal)
    }
    .padding()
    .background(Color("AppBackground"))
}
