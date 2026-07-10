//
//  FoodDNAViewModel.swift
//  MangoProject
//
//  Created by Muthiara Putri Aliyu on 10/07/26.
//


import Foundation

@Observable
final class FoodDNAViewModel {
    /// Whether a menu scan is currently loaded. False = empty/pre-scan state.
    var hasScannedMenu: Bool = true

    var dishes: [DishDisplayModel] = DishDisplayModel.mockList

    var overallStatus: DishDNAStatus {
        if dishes.contains(where: { $0.status == .nonHalal }) {
            return .nonHalal
        }
        if dishes.contains(where: { $0.status == .needsVerification }) {
            return .halal
        }
        return .halal
    }

    /// Clears the current scan and returns to the empty pre-scan state.
    func resetScan() {
        hasScannedMenu = false
        dishes = []
    }

    /// Placeholder for triggering a new scan. Currently just re-populates
    /// mock data — will call a real scan/NFC service later.
    func startScan() {
        dishes = DishDisplayModel.mockList
        hasScannedMenu = true
    }
}
