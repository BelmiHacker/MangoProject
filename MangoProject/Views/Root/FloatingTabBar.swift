import SwiftUI

struct FloatingTabBar: View {
    @Binding var selectedTab: RootTab

    private let accent = Color(red: 0.18, green: 0.42, blue: 0.35)

    var body: some View {
        HStack(spacing: 0) {
            ForEach(RootTab.allCases, id: \.self) { tab in
                TabItemButton(
                    tab: tab,
                    isSelected: selectedTab == tab,
                    accent: accent
                ) {
                    selectedTab = tab
                }
            }
        }
        .padding(8)
        .background(Color(.systemBackground))
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.08), radius: 14, x: 0, y: 3)
    }

    var searchButton: some View {
        Button(action: onSearchTap) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.white)
        }
        .frame(width: 68, height: 68)
        .background {
            if #available(iOS 26, *) {
                Circle()
                    .fill(.clear)
                    .glassEffect(in: Circle())
            } else {
                Circle()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Circle()
                            .fill(Color.white.opacity(0.25))
                    )
                    .overlay(
                        Circle()
                            .strokeBorder(Color.white.opacity(0.5), lineWidth: 0.5)
                    )
            }
        }
        .clipShape(Circle())
        .shadow(color: .black.opacity(0.08), radius: 14, x: 0, y: 3)
        .accessibilityLabel("Search")
    }
}

// MARK: - Tab Item Button

private struct TabItemButton: View {
    let tab: RootTab
    let isSelected: Bool
    let accent: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: isSelected ? tab.selectedIcon : tab.icon)
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(isSelected ? accent : Color.primary)

                Text(tab.label)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(isSelected ? accent : Color.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .padding(.horizontal, 4)
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color(.systemGray5))
                }
            }
            .animation(.spring(response: 0.28, dampingFraction: 0.72), value: isSelected)
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .accessibilityLabel(tab.label)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        @State private var tab: RootTab = .home
        var body: some View {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                VStack {
                    Spacer()
                    FloatingTabBar(selectedTab: $tab)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 40)
                }
            }
        }
    }
    return PreviewWrapper()
}
