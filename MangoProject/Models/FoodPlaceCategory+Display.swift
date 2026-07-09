//
//  FoodPlaceCategory+Display.swift
//  MangoProject
//
//  Created by Muthiara Putri Aliyu on 09/07/26.
//


import Foundation

extension FoodPlaceCategory {
    /// User-facing label for this category, e.g. shown on restaurant cards.
    var displayName: String {
        switch self {
        case .indonesian:
            return "Indonesian"
        case .dessert:
            return "Dessert"
        case .cafe:
            return "Cafe"
        case .bakery:
            return "Bakery"
        case .chinese:
            return "Chinese"
        case .western:
            return "Western"
        case .asian:
            return "Asian"
        case .middleEastern:
            return "Middle Eastern"
        case .healthy:
            return "Healthy"
        case .beverages:
            return "Beverages"
        case .sushi:
            return "Sushi"
        }
    }
}
