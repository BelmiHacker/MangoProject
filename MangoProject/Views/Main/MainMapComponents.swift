//
//  MainMapComponents.swift
//  MangoProject
//
//  Created by Belmiro Kayru on 05/07/26.
//

import SwiftUI

// MARK: - Status

struct StatusRow: View {
    let systemImage: String
    let text: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: systemImage)
                .font(.system(size: 22, weight: .bold))
                .frame(width: 26)

            Text(text)
                .font(.system(size: 22, weight: .bold))
                .lineLimit(1)
                .minimumScaleFactor(0.65)
        }
        .foregroundStyle(.primary)
    }
}

// MARK: - Empty and Loading States

struct LoadingPlaceCard: View {
    var body: some View {
        MessageCard(text: "Loading Apple Maps halal food results...")
    }
}

struct MessageCard: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 20, weight: .semibold))
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}
