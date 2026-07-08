//
//  DirectionSummaryCard.swift
//  MangoProject
//

import SwiftUI

struct DirectionSummaryCard: View {

    let durationText: String
    let etaText: String
    let distanceText: String
    let destinationName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Image(systemName: "figure.walk")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.85))
                Text(durationText)
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(.white)
                Spacer()
            }
            Text("ETA \(etaText) · \(distanceText)")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.9))
            Text(destinationName)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
                .lineLimit(1)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBlue))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}
