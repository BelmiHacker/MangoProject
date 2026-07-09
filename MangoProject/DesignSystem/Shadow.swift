//
//  Untitled.swift
//  MangoProject
//
//  Created by Muthiara Putri Aliyu on 09/07/26.
//

//
//  Shadow.swift
//  MangoProject
//
//  DesignSystem
//

import SwiftUI

/// Centralized shadow styles for the app.
/// Use these instead of ad-hoc `.shadow()` calls so elevation looks
/// consistent across all cards and elevated surfaces.
enum Shadow {
    /// Standard card elevation — restaurant cards, points card, recent search cards
    static let card = ShadowStyle(
        color: .black.opacity(0.08),
        radius: 12,
        x: 0,
        y: 4
    )

    /// Subtle elevation for smaller floating elements (e.g. bookmark button)
    static let subtle = ShadowStyle(
        color: .black.opacity(0.06),
        radius: 6,
        x: 0,
        y: 2
    )
}

/// Simple value type describing a shadow, so it can be applied
/// via a single reusable view modifier instead of four separate parameters.
struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

extension View {
    /// Applies a centralized `ShadowStyle` to any view.
    /// Usage: `.appShadow(Shadow.card)`
    func appShadow(_ style: ShadowStyle) -> some View {
        self.shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
    }
}
