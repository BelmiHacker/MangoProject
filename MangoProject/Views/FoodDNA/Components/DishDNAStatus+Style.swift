//
//  DishDNAStatus+Style.swift
//  MangoProject
//

import SwiftUI

/// Centralizes every color and copy string the Food DNA result cards need
/// per status, so DishRow/FoodDNASummaryCard read from one place instead
/// of each repeating their own switch statement.
extension DishDNAStatus {
    /// Short badge label shown under the dish name, e.g. "Likely Halal".
    /// No confidence percentage is shown — the backend doesn't return one,
    /// and this screen never fabricates a number it can't back up.
    var badgeLabel: String {
        switch self {
        case .halal: "Likely Halal"
        case .needsVerification: "Needs Caution"
        case .nonHalal: "Not Halal"
        }
    }

    /// Heading for the "why" section inside the expanded card.
    var reasonSectionTitle: String {
        switch self {
        case .halal: "Why it appears halal"
        case .needsVerification: "Why it needs caution"
        case .nonHalal: "Why it appears non-halal"
        }
    }

    /// Background for the expanded card surface.
    var expandedBackground: Color {
        switch self {
        case .halal: Color("StatusHalalLight")
        case .needsVerification: Color("StatusWarningLight")
        case .nonHalal: Color("StatusDangerLight")
        }
    }

    /// 1pt border drawn around the expanded card.
    var cardBorder: Color {
        switch self {
        case .halal: Color("StatusHalalBorder")
        case .needsVerification: Color("StatusWarningBorder")
        case .nonHalal: Color("StatusDangerBorder")
        }
    }

    /// Primary accent used for section icons, the collapsed status label,
    /// and the concern list icon/text color.
    var accentColor: Color {
        switch self {
        case .halal: Color("StatusHalalDark")
        case .needsVerification: Color("StatusWarningDark")
        case .nonHalal: Color("StatusDangerDark")
        }
    }

    /// Glyph color for the status icon inside its soft circular container —
    /// brighter than `accentColor` for halal so the check mark pops.
    var iconGlyphColor: Color {
        switch self {
        case .halal: Color("StatusHalalHighlight")
        case .needsVerification, .nonHalal: accentColor
        }
    }

    /// Soft-tinted background for the icon container and the status badge.
    var badgeBackground: Color {
        switch self {
        case .halal: Color("StatusHalalBadgeBackground")
        case .needsVerification: Color("StatusWarningLight")
        case .nonHalal: Color("StatusDangerLight")
        }
    }

    /// Text color used on top of `badgeBackground`.
    var badgeText: Color {
        switch self {
        case .halal: Color("StatusHalalBadgeText")
        case .needsVerification: Color("StatusWarningDark")
        case .nonHalal: Color("StatusDangerDark")
        }
    }
}
