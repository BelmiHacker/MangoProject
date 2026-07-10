import Foundation

nonisolated enum RootTab: Hashable, CaseIterable {
    case home
    case explore
    case foodDNA
    case points

    var label: String {
        switch self {
        case .home:    "Home"
        case .explore: "Explore"
        case .foodDNA: "Food DNA"
        case .points:  "Points"
        }
    }

    /// The native Liquid Glass tab bar renders every tab icon in its
    /// filled style regardless of selection state (verified in Simulator:
    /// deselecting a tab does not revert its icon to an outline glyph),
    /// conveying selection through tint alone — so only the filled variant
    /// is kept here, matching what's actually shown on screen.
    var icon: String {
        switch self {
        case .home:    "house.fill"
        case .explore: "map.fill"
        case .foodDNA: "fork.knife"
        case .points:  "star.fill"
        }
    }
}
