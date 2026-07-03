//
//  Stamp.swift
//  MangoProject
//
//  Created by Belmiro Kayru on 03/07/26.
//

import Foundation

struct Stamp: Identifiable {
    let id: String
    let foodPlaceId: String
    let currentCount: Int
    let targetCount: Int
    let rewardDescription: String
}
