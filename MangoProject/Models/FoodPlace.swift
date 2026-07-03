//
//  FoodPlace.swift
//  MangoProject
//
//  Created by Belmiro Kayru on 03/07/26.
//

import Foundation
import CoreLocation

struct FoodPlace: Identifiable {
    let id: String
    let businessName: String
    let name: String
    let address: String
    let rating: Double?
    let openingTime: String?
    let closingTime: String?
    let category: FoodPlaceCategory
    let coordinate: CLLocationCoordinate2D
    let floor: String?
    let imageName: String?
    let certification: Certification
}
