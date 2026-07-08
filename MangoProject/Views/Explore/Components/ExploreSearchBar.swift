//
//  ExploreSearchBar.swift
//  MangoProject
//

import SwiftUI

struct ExploreSearchBar: View {

    @Binding var text: String
    let onClear: () -> Void

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("Search halal food...", text: $text)
                .focused($isFocused)
                .autocorrectionDisabled()

            Spacer(minLength: 0)

            if text.isEmpty {
                Image(systemName: "mic.fill")
                    .foregroundStyle(.secondary)
            } else {
                Button {
                    onClear()
                    isFocused = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
