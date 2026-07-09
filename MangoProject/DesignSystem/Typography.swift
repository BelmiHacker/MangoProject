//
//  Typography.swift
//  MangoProject
//
//  Created by Muthiara Putri Aliyu on 09/07/26.
//

import SwiftUI

/// Centralized type scale for the app, built on Dynamic Type text styles
/// so the UI respects the user's accessibility text-size settings.
/// Use these instead of ad-hoc `.font()` calls so type hierarchy stays
/// consistent across screens.
enum Typography {
    /// Large screen title, e.g. "Hello Muthi!"
    static let screenTitle: Font = .system(.largeTitle, design: .rounded, weight: .bold)

    /// Section headers, e.g. "Recommended For You", "Recently Searched"
    static let sectionHeader: Font = .system(.title3, design: .rounded, weight: .bold)

    /// Card titles, e.g. restaurant name
    static let cardTitle: Font = .system(.headline, design: .default, weight: .semibold)

    /// Card metadata line, e.g. "Indonesian - 0.1 meter"
    static let cardSubtitle: Font = .system(.subheadline, design: .default, weight: .regular)

    /// Secondary/supporting text, e.g. greeting subtitle, address line
    static let bodySecondary: Font = .system(.subheadline, design: .default, weight: .regular)

    /// Small metadata text, e.g. rating number
    static let caption: Font = .system(.caption, design: .default, weight: .medium)
}
