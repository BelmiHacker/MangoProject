//
//  FoodDNAAnalysisResult.swift
//  MangoProject
//
//  Created by Muthiara Putri Aliyu on 11/07/26.
//


import Foundation

struct FoodDNAAnalysisResult: Codable {
    let summary: FoodDNASummary
    let menuItems: [MenuItemAnalysis]

    enum CodingKeys: String, CodingKey {
        case summary
        case menuItems = "menu_items"
    }
}

struct FoodDNASummary: Codable {
    let summaryText: String
    let overallStatus: String
    let totalItems: Int
    let likelyHalal: Int
    let needsCaution: Int
    let likelyHaram: Int

    enum CodingKeys: String, CodingKey {
        case summaryText = "summary_text"
        case overallStatus = "overall_status"
        case totalItems = "total_items"
        case likelyHalal = "likely_halal"
        case needsCaution = "needs_caution"
        case likelyHaram = "likely_haram"
    }
}

struct MenuItemAnalysis: Codable, Identifiable {
    var id: String { name }
    let name: String
    let status: String
    let reason: String
    let ingredients: [IngredientAnalysis]
}

struct IngredientAnalysis: Codable, Identifiable, Hashable {
    var id: String { name }
    let name: String
    let status: String
}
