//
//  FoodDNAViewModel.swift
//  MangoProject
//
//  Created by Muthiara Putri Aliyu on 10/07/26.
//


import Foundation
import UIKit

@Observable
final class FoodDNAViewModel {
    var hasScannedMenu: Bool = false
    var dishes: [DishDisplayModel] = []
    var isAnalyzing: Bool = false
    var errorMessage: String?

    private let service = FoodDNAAnalysisService()

    var overallStatus: DishDNAStatus {
        if dishes.contains(where: { $0.status == .nonHalal }) {
            return .nonHalal
        }
        if dishes.contains(where: { $0.status == .needsVerification }) {
            return .needsVerification
        }
        return .halal
    }

    /// Uploads the given menu photo and updates state with the real result.
    /// Surfaces failures via `errorMessage` rather than ever substituting
    /// fake data.
    @MainActor
    func analyzeMenu(image: UIImage) async {
        isAnalyzing = true
        errorMessage = nil

        do {
            let result = try await service.analyzeMenu(image: image)
            dishes = result.menuItems.map(Self.mapToDisplayModel)
            hasScannedMenu = true
        } catch {
            errorMessage = "We couldn't analyze this menu. Please try again."
            hasScannedMenu = false
        }

        isAnalyzing = false
    }

    func resetScan() {
        hasScannedMenu = false
        dishes = []
        errorMessage = nil
    }

    /// Maps a raw backend MenuItemAnalysis into the UI-facing DishDisplayModel.
    /// This is the one place backend response shape meets the view layer —
    /// keeps every DishRow/DishRowExpandedContent decoupled from API format.
    private static func mapToDisplayModel(_ item: MenuItemAnalysis) -> DishDisplayModel {
        let status = DishDNAStatus.from(rawStatus: item.status)

        return DishDisplayModel(
            id: item.id,
            name: item.name,
            status: status,
            detectedIngredients: item.ingredients.map { $0.name },
            concerns: status == .halal ? [] : [item.reason],
            summaryText: status == .halal ? item.reason : nil
        )
    }
}
