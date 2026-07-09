import Foundation

enum RootTab: Hashable, CaseIterable {
    case home
    case explore
    case foodDNA
    case points

    var label: String {
        switch self {
        case .home:    return "Home"
        case .explore: return "Explore"
        case .foodDNA: return "Food DNA"
        case .points:  return "Points"
        }
    }

    var icon: String {
        switch self {
        case .home:    return "house"
        case .explore: return "map"
        case .foodDNA: return "fork.knife"
        case .points:  return "star"
        }
    }

    var selectedIcon: String {
        switch self {
        case .home:    return "house.fill"
        case .explore: return "map.fill"
        case .foodDNA: return "fork.knife"
        case .points:  return "star.fill"
        }
    }
}
