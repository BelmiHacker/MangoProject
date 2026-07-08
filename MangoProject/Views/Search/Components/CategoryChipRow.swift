import SwiftUI

struct CategoryChipRow: View {
    @Binding var selected: String

    private let categories = ["All", "Chinese", "Western", "Asian", "Middle-Eastern", "Indonesian", "Cafe", "Desserts", "Restaurant"]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(categories, id: \.self) { category in
                    chip(for: category)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func chip(for category: String) -> some View {
        let isSelected = selected == category
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selected = category
            }
        } label: {
            Text(category)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(isSelected ? Color.white : Color.primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 9)
                .background {
                    if isSelected {
                        Capsule().fill(Color.black)
                    } else {
                        Capsule()
                            .fill(Color(.systemBackground))
                            .overlay(Capsule().strokeBorder(Color(.systemGray4), lineWidth: 1))
                    }
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(category)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var selected = "All"
        var body: some View {
            CategoryChipRow(selected: $selected)
                .padding(.vertical)
        }
    }
    return PreviewWrapper()
}
