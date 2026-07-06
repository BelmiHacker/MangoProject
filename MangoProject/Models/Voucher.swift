//
//  Voucher.swift
//  MangoProject
//
//  Created by Belmiro Kayru on 03/07/26.
//

import Foundation

struct Voucher: Identifiable {
    let id: String
    let foodPlaceId: String
    let title: String
    let description: String
    let validUntil: Date?
    let code: String?
    let isRedeemed: Bool
}
