import SwiftUI

// MARK: - FloatingTabBar

struct FloatingTabBar: View {
    @Binding var selectedTab: RootTab
    var onSearchTap: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            tabCapsule
            searchButton
        }
    }
}

// MARK: - Private subviews

private extension FloatingTabBar {

    var tabCapsule: some View {
        HStack(spacing: 0) {
            ForEach(RootTab.allCases, id: \.self) { tab in
                TabItemButton(
                    tab: tab,
                    isSelected: selectedTab == tab
                ) {
                    selectedTab = tab
                }
            }
        }
        .padding(8)
        // iOS 26+: true Liquid Glass via the system glass effect.
        // iOS 25 and below: frosted ultraThinMaterial as a close fallback.
        .background {
            if #available(iOS 26, *) {
                Capsule()
                    .fill(.clear)
                    .glassEffect(in: Capsule())
            } else {
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Capsule()
                            .fill(Color.white.opacity(0.25))
                    )
                    .overlay(
                        Capsule()
                            .strokeBorder(Color.white.opacity(0.5), lineWidth: 0.5)
                    )
            }
        }
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.08), radius: 14, x: 0, y: 3)
    }

    var searchButton: some View {
        Button(action: onSearchTap) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.primary)
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

// MARK: - TabItemButton

private struct TabItemButton: View {
    let tab: RootTab
    let isSelected: Bool
    let action: () -> Void

    private let accent = Color(red: 0.18, green: 0.42, blue: 0.35)

    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: isSelected ? tab.selectedIcon : tab.icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(isSelected ? accent : Color.primary)

                Text(tab.label)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(isSelected ? accent : Color.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .padding(.horizontal, 8)
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    // On glass, a soft white tint reads better than systemGray5
                    .fill(isSelected ? Color.white.opacity(0.35) : .clear)
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

#Preview("Liquid Glass Tab Bar") {
    struct PreviewWrapper: View {
        @State private var tab: RootTab = .home

        var body: some View {
            ZStack {
                // Colourful background so the glass effect is visible in preview
                LinearGradient(
                    colors: [Color.teal.opacity(0.4), Color.mint.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack {
                    Spacer()
                    FloatingTabBar(selectedTab: $tab, onSearchTap: {})
                        .padding(.horizontal, 16)
                        .padding(.bottom, 40)
                }
            }
        }
    }
    return PreviewWrapper()
}
