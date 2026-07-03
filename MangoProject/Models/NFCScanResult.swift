//
//  NFCScanResult.swift
//  MangoProject
//
//  Created by Belmiro Kayru on 03/07/26.
//

import Foundation

struct NFCScanResult {
    let foodPlaceId: String
    let scannedAt: Date
    let status: NFCScanStatus
    let message: String?
}
