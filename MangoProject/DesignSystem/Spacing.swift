//
//  Spacing.swift
//  MangoProject
//
//  Created by Muthiara Putri Aliyu on 09/07/26.
//

import Foundation

/// Centralized spacing scale for the app.
/// Use these instead of hardcoded padding/spacing values so layout
/// stays consistent across screens and is easy to retune globally.
enum Spacing {
    /// 4pt — tight spacing between tightly related elements (e.g. icon + label)
    static let xxs: CGFloat = 4

    /// 8pt — small gaps (e.g. between a title and its subtitle)
    static let xs: CGFloat = 8

    /// 12pt — spacing between elements within the same card
    static let small: CGFloat = 12

    /// 16pt — standard horizontal screen padding, default gap between components
    static let medium: CGFloat = 16

    /// 20pt — internal card padding
    static let cardPadding: CGFloat = 20

    /// 24pt — spacing between distinct sections (e.g. "Recommended For You" to next section)
    static let section: CGFloat = 24

    /// 32pt — larger separation, e.g. below the header before the points card
    static let large: CGFloat = 32
}
