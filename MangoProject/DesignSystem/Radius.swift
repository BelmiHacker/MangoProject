//
//  Radius.swift
//  MangoProject
//
//  Created by Muthiara Putri Aliyu on 09/07/26.
//

import Foundation

/// Centralized corner radius scale for the app.
/// Use these instead of hardcoded `.cornerRadius()` / `RoundedRectangle` values
/// so shape language stays consistent across all cards, buttons, and containers.
enum Radius {
    /// 12pt — smaller elements (e.g. bookmark button background, small chips)
    static let small: CGFloat = 12

    /// 20pt — standard card radius (restaurant cards, points card, recent search cards)
    static let card: CGFloat = 20

    /// 16pt — Food DNA dish result cards
    static let dishCard: CGFloat = 16

    /// 999pt — fully rounded / pill shape (e.g. circular profile button, tab bar container)
    static let pill: CGFloat = 999
}
