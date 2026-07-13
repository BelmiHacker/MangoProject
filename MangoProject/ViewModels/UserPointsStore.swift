//
//  UserPointsStore.swift
//  MangoProject
//

import Foundation

/// Single source of truth for the user's halal reward points. Owned once at
/// the root and shared between MainView (Home) and PointsPageView so that
/// earning points via NFC/QR on either screen is reflected on both —
/// previously each screen kept its own separate counter.
@Observable
final class UserPointsStore {
    var points: Int = 67
}
