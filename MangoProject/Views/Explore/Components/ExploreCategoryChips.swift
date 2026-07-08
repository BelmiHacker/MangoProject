//
//  ExploreCategoryChips.swift
//  MangoProject
//

import SwiftUI

struct ExploreCategoryChips: View {

    let categories: [String]
    let selectedCategories: Set<String>
    let onSelect: (String) -> Void

    private let accent = Color(red: 0.18, green: 0.42, blue: 0.35)

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(categories, id: \.self) { category in
                    Button { onSelect(category) } label: {
                        Text(category)
                            .font(.subheadline.weight(.medium))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(selectedCategories.contains(category) ? accent : Color.primary.opacity(0.1))
                            .foregroundStyle(selectedCategories.contains(category) ? .white : .primary)
                            .clipShape(Capsule())
                            .animation(.spring(response: 0.28, dampingFraction: 0.7), value: selectedCategories.contains(category))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
    }
}
