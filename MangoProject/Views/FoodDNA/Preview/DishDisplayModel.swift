//
//  DishDisplayModel.swift
//  MangoProject
//
//  Created by Muthiara Putri Aliyu on 10/07/26.

//  ⚠️ TEMPORARY UI-ONLY MODEL — NOT A DOMAIN MODEL.
//  This exists only to drive the Food DNA screen UI while no backend/NFC
//  analysis pipeline is connected yet.
//
//  When real data work begins, this should be REPLACED (not extended) by a
//  real model — likely a new `DishAnalysis` / `FoodDNAResult` model, and/or
//  an extended `HalalStatus` enum with a third case for "needs verification."
//  That decision belongs to whoever owns the Models layer, not to this file.
//
//  Do NOT import this into ViewModels or Services once real data exists.
//

import Foundation

/// Per-dish halal analysis status. Mirrors what a future extended
/// `HalalStatus` model will likely need — currently `HalalStatus` only
/// has `.certified` / `.notCertified`, which can't represent "needs
/// verification." Kept separate here rather than guessing at that change.
enum DishDNAStatus {
    case halal
    case needsVerification
    case nonHalal
}

struct DishDisplayModel: Identifiable, Hashable {
    let id: String
    let name: String
    let status: DishDNAStatus
    let detectedIngredients: [String]
    let concerns: [String]
    let summaryText: String?
}

extension DishDisplayModel {
    static let mockList: [DishDisplayModel] = [
        DishDisplayModel(
            id: "1",
            name: "Bakwan Bacon",
            status: .halal,
            detectedIngredients: [],
            concerns: [],
            summaryText: "Every detected menu item has a high halal confidence. Enjoy your meal with confidence, and ask the restaurant if you have additional dietary concerns."
        ),
        DishDisplayModel(
            id: "2",
            name: "Bakwan Bacon",
            status: .needsVerification,
            detectedIngredients: ["Flour", "Carrot", "Bacon", "Vegetable Oil"],
            concerns: ["Bacon type is unclear (Pork or beef?)", "Flour type is unknown"],
            summaryText: nil
        ),
        DishDisplayModel(
            id: "3",
            name: "Bakwan Pork Bacon",
            status: .nonHalal,
            detectedIngredients: ["Flour", "Carrot", "Pork Bacon", "Vegetable Oil"],
            concerns: ["Pork bacon is not halal"],
            summaryText: nil
        )
    ]
}

extension DishDNAStatus {
    /// Screen-level summary title, e.g. shown in FoodDNASummaryCard.
    var summaryTitle: String {
        switch self {
        case .halal: return "All detected dishes appear to be halal."
        case .needsVerification: return "Some detected dishes need verification."
        case .nonHalal: return "Potential non-halal dishes detected."
        }
    }

    var summaryDescription: String {
        switch self {
        case .halal:
            return "Every detected menu item has a high halal confidence. Enjoy your meal with confidence, and ask the restaurant if you have additional dietary concerns."
        case .needsVerification:
            return "One or more menu items contain ingredients that couldn't be verified. Please confirm with the restaurant staff before ordering."
        case .nonHalal:
            return "One or more detected dishes contain ingredients with a high risk of being non-halal. We recommend avoiding these dishes unless verified by the restaurant."
        }
    }

    var iconName: String {
        switch self {
        case .halal: return "checkmark"
        case .needsVerification: return "exclamationmark.triangle.fill"
        case .nonHalal: return "xmark"
        }
    }
}
