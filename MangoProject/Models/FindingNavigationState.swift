//
//  FindingNavigationState.swift
//  MangoProject
//

import Foundation

struct NavigationStep: Identifiable {
    let id: Int
    let instruction: String
    let distanceText: String
    let symbolName: String

    static func symbol(for instruction: String) -> String {
        let t = instruction.lowercased()
        if t.contains("arrive") { return "mappin.circle.fill" }
        if t.contains("turn left") { return "arrow.turn.up.left" }
        if t.contains("turn right") { return "arrow.turn.up.right" }
        if t.contains("u-turn") { return "arrow.uturn.left" }
        if t.contains("keep left") { return "arrow.turn.up.left" }
        if t.contains("keep right") { return "arrow.turn.up.right" }
        return "arrow.up"
    }
}

struct FindingNavigationState {
    let targetName: String
    let distanceText: String
    let directionPrefixText: String
    let directionFocusText: String
    let arrowAngle: Double
    let instructionDistanceText: String
    let instructionText: String
    let stepProgress: Int
    let stepCount: Int
    let proximityProgress: Double
    let steps: [NavigationStep]
}
