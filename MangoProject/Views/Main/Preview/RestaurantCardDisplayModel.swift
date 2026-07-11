//  RestaurantCardDisplayModel.swift
//  MangoProject
//
//  Created by Muthiara Putri Aliyu on 09/07/26.
//  Views/Main/Preview Content
//
//  ⚠️ TEMPORARY UI-ONLY MODEL — NOT A DOMAIN MODEL.
//  This exists only to drive the UI for RestaurantCardView / RecentRestaurantCardView
//  while no backend/API is connected yet.
//
//  When real data work begins, this should be REPLACED (not extended) by whichever
//  real model ends up backing restaurant cards — likely a new `FoodPlace` model,
//  or an extended/wrapped version of `NearbyFoodPlace`. That decision belongs to
//  whoever owns the Models layer, not to this file.
//
//  Do NOT import this into ViewModels or Services once real data exists.
//

import Foundation
import CoreLocation
import MapKit

struct RestaurantCardDisplayModel: Identifiable, Hashable {
    let id: String
    let name: String
    let categoryDisplayName: String
    let distanceText: String
    let rating: Double
    let descriptionText: String
    let addressText: String
    let isBookmarked: Bool

    /// Placeholder-only. Real image handling (AsyncImage / URL / bundled asset)
    /// will be decided once the backend/image strategy is finalized.
    let imagePlaceholderSymbol: String
    var nearbyPlace: NearbyFoodPlace?
}

extension RestaurantCardDisplayModel {
    /// Mock data for previews and initial UI-only development.
    static let mockList: [RestaurantCardDisplayModel] = [
        RestaurantCardDisplayModel(
            id: "1",
            name: "Jalarasa The Breeze",
            categoryDisplayName: "Indonesian",
            distanceText: "0.1 meter",
            rating: 4.2,
            descriptionText: "Lorem ipsum dolor sit amet siete mi piace habite avec toi",
            addressText: "BSD, Tangerang",
            isBookmarked: false,
            imagePlaceholderSymbol: "photo"
        ),
        RestaurantCardDisplayModel(
            id: "2",
            name: "Jalarasa The Breeze",
            categoryDisplayName: "Indonesian",
            distanceText: "0.1 meter",
            rating: 4.2,
            descriptionText: "Lorem ipsum dolor sit amet siete mi piace habite avec toi",
            addressText: "BSD, Tangerang",
            isBookmarked: true,
            imagePlaceholderSymbol: "photo"
        )
    ]

    static let mock = mockList[0]
}
