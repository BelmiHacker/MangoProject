//
//  UserProfile.swift
//  MangoProject
//
//  Created by Belmiro Kayru on 03/07/26.
//

import Foundation

struct UserProfile: Identifiable {
    let id: String
    let name: String
    let favoriteFoodPlaceIds: [String]
    let stampIds: [String]
}
