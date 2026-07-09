//
//  DirectionStepsList.swift
//  MangoProject
//

import MapKit
import SwiftUI

struct DirectionStepsList: View {

    let steps: [MKRoute.Step]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Route Overview")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 20)
                .padding(.top, 14)
                .padding(.bottom, 4)

            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                DirectionStepRow(step: step, isLast: index == steps.count - 1)
                    .padding(.horizontal, 20)

                if index < steps.count - 1 {
                    Divider()
                        .padding(.leading, 70)
                }
            }
        }
    }
}
