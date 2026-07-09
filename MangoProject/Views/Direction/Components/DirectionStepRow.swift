//
//  DirectionStepRow.swift
//  MangoProject
//

import MapKit
import SwiftUI

struct DirectionStepRow: View {

    let step: MKRoute.Step
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color(.systemBlue).opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: stepIcon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.blue)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(step.instructions)
                    .font(.subheadline)
                    .fixedSize(horizontal: false, vertical: true)
                if step.distance > 0 {
                    Text(distanceText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 10)
    }

    private var stepIcon: String {
        let t = step.instructions.lowercased()
        if isLast || t.contains("arrive") { return "mappin.circle.fill" }
        if t.contains("turn left") { return "arrow.turn.up.left" }
        if t.contains("turn right") { return "arrow.turn.up.right" }
        if t.contains("u-turn") { return "arrow.uturn.left" }
        return "arrow.up"
    }

    private var distanceText: String {
        step.distance >= 1000
            ? String(format: "%.1f km", step.distance / 1000)
            : "\(Int(step.distance.rounded())) m"
    }
}
