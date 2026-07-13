//
//  ExpandedSectionHeader.swift
//  MangoProject
//

import SwiftUI

/// Small icon + title row used to label each section of a dish's expanded
/// analysis (e.g. "Why it appears halal", "Things to check").
struct ExpandedSectionHeader: View {
    let icon: String
    let title: String
    var tint: Color = Color("DishTitleText")

    var body: some View {
        HStack(spacing: Spacing.xxs) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(tint)

            Text(title)
                .font(Typography.cardSubtitle)
                .fontWeight(.semibold)
                .foregroundStyle(Color("DishTitleText"))
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: Spacing.small) {
        ExpandedSectionHeader(icon: "checkmark.seal.fill", title: "Why it appears halal", tint: Color("StatusHalalDark"))
        ExpandedSectionHeader(icon: "magnifyingglass", title: "Things to check", tint: Color("StatusWarningDark"))
        ExpandedSectionHeader(icon: "hand.raised.fill", title: "Suggested action", tint: Color("StatusDangerDark"))
    }
    .padding()
    .background(Color("AppBackground"))
}
