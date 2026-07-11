//
//  StatusRow.swift
//  MangoProject
//

import SwiftUI

struct StatusRow: View {
    let systemImage: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.secondary)
                .frame(width: 24)

            Text(text)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.primary)
        }
    }
}
