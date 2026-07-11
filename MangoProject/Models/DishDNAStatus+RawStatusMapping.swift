//
//  DishDNAStatus+RawStatusMapping.swift
//  MangoProject
//
//  Created by Muthiara Putri Aliyu on 11/07/26.

//  Maps the backend's free-text status strings (e.g. "Likely Halal",
//  "Needs Caution", "Haram") onto our safer DishDNAStatus enum.
//  Centralizing this mapping means if the backend adds/changes status
//  strings, only this one function needs updating.
//

import Foundation

extension DishDNAStatus {
    /// Maps a raw backend status string to DishDNAStatus.
    /// Falls back to `.needsVerification` for any unrecognized string —
    /// erring toward caution rather than silently assuming halal.
    static func from(rawStatus: String) -> DishDNAStatus {
        let normalized = rawStatus.lowercased()

        if normalized.contains("haram") {
            return .nonHalal
        }
        if normalized.contains("caution") || normalized.contains("syubhat") || normalized.contains("perhatian") {
            return .needsVerification
        }
        if normalized.contains("halal") {
            return .halal
        }
        // Unknown status string — treat as needing verification rather
        // than assuming it's safe. Flag: worth logging this case in
        // production so unmapped backend strings get caught early.
        return .needsVerification
    }
}
