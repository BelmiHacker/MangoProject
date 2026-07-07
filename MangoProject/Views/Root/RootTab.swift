import Foundation

enum RootTab: Hashable, CaseIterable {
    case home
    case scan
    case profile

    var label: String {
        switch self {
        case .home:    return "Home"
        case .scan:    return "Scan"
        case .profile: return "Profile"
        }
    }

    // Unselected SF Symbol name
    var icon: String {
        switch self {
        case .home:    return "house"
        case .scan:    return "doc.viewfinder"
        case .profile: return "person.circle"
        }
    }

    // Selected SF Symbol name (filled variants where available)
    var selectedIcon: String {
        switch self {
        case .home:    return "house.fill"
        case .scan:    return "doc.viewfinder"
        case .profile: return "person.circle.fill"
        }
    }
}
