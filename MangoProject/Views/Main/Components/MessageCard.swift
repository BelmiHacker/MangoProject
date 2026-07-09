//
//  MessageCard.swift
//  MangoProject
//

import SwiftUI

struct MessageCard: View {
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "info.circle")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.secondary)

            Text(text)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
