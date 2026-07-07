import SwiftUI

struct RootTabView: View {
    @State private var selectedTab: RootTab = .home
    @State private var isSearchPresented = false
    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool
    @Namespace private var barNamespace

    var body: some View {
        tabContentStack
            .safeAreaInset(edge: .bottom, spacing: 0) {
                morphingBar
            }
    }
}

// MARK: - Content Stack

private extension RootTabView {
    var tabContentStack: some View {
        ZStack {
            MainMapPageView()
                .opacity(selectedTab == .home && !isSearchPresented ? 1 : 0)
                .allowsHitTesting(selectedTab == .home && !isSearchPresented)
                .accessibilityHidden(selectedTab != .home || isSearchPresented)

            NavigationStack {
                ProfileView()
            }
            .opacity(selectedTab == .profile && !isSearchPresented ? 1 : 0)
            .allowsHitTesting(selectedTab == .profile && !isSearchPresented)
            .accessibilityHidden(selectedTab != .profile || isSearchPresented)

            SearchView(
                searchText: $searchText,
                isSearchFocused: isSearchFocused
            )
            .opacity(isSearchPresented ? 1 : 0)
            .allowsHitTesting(isSearchPresented)
            .accessibilityHidden(!isSearchPresented)
        }
        .animation(.easeInOut(duration: 0.25), value: isSearchPresented)
    }
}

// MARK: - Morphing Bar

private extension RootTabView {
    private var accent: Color { Color(red: 0.18, green: 0.42, blue: 0.35) }

    var morphingBar: some View {
        HStack(spacing: 12) {
            if isSearchPresented {
                // Left: Home circle
                Button {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
                        isSearchPresented = false
                        searchText = ""
                        isSearchFocused = false
                    }
                } label: {
                    Image(systemName: "house.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.primary)
                        .frame(width: 56, height: 56)
                        .background { glassCircle }
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.08), radius: 14, x: 0, y: 3)
                }
                .buttonStyle(.plain)
                .matchedGeometryEffect(id: "leftBar", in: barNamespace)
                .transition(.scale(scale: 0.5).combined(with: .opacity))
                .accessibilityLabel("Back to home")

                // Right: Search field
                searchFieldView
                    .matchedGeometryEffect(id: "rightBar", in: barNamespace)
                    .transition(.opacity)

            } else {
                // Left: Tab capsule
                tabCapsuleView
                    .matchedGeometryEffect(id: "leftBar", in: barNamespace)
                    .transition(.scale(scale: 0.9, anchor: .leading).combined(with: .opacity))

                // Right: Search circle
                Button {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
                        isSearchPresented = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isSearchFocused = true
                    }
                } label: {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 68, height: 68)
                        .background { glassCircle }
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.08), radius: 14, x: 0, y: 3)
                }
                .buttonStyle(.plain)
                .matchedGeometryEffect(id: "rightBar", in: barNamespace)
                .transition(.opacity)
                .accessibilityLabel("Search")
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }

    var tabCapsuleView: some View {
        HStack(spacing: 0) {
            ForEach(RootTab.allCases, id: \.self) { tab in
                tabItemButton(tab)
            }
        }
        .padding(8)
        .background { glassCapsule }
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.08), radius: 14, x: 0, y: 3)
    }

    func tabItemButton(_ tab: RootTab) -> some View {
        Button {
            guard tab != .scan else { return }
            selectedTab = tab
        } label: {
            VStack(spacing: 3) {
                Image(systemName: selectedTab == tab ? tab.selectedIcon : tab.icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(selectedTab == tab ? accent : Color.primary)
                Text(tab.label)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(selectedTab == tab ? accent : Color.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .padding(.horizontal, 8)
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(selectedTab == tab ? Color.white.opacity(0.35) : .clear)
            }
            .animation(.spring(response: 0.28, dampingFraction: 0.72), value: selectedTab)
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .accessibilityLabel(tab.label)
        .accessibilityAddTraits(selectedTab == tab ? .isSelected : [])
    }

    var searchFieldView: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.secondary)

            TextField("Search restaurant name, area", text: $searchText)
                .focused($isSearchFocused)
                .submitLabel(.search)
                .font(.system(size: 16))

            if !searchText.isEmpty {
                Button { searchText = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 56)
        .background { glassCapsule }
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.08), radius: 14, x: 0, y: 3)
    }

    @ViewBuilder var glassCapsule: some View {
        if #available(iOS 26, *) {
            Capsule().fill(.clear).glassEffect(in: Capsule())
        } else {
            Capsule().fill(.ultraThinMaterial)
                .overlay(Capsule().fill(Color.white.opacity(0.25)))
                .overlay(Capsule().strokeBorder(Color.white.opacity(0.5), lineWidth: 0.5))
        }
    }

    @ViewBuilder var glassCircle: some View {
        if #available(iOS 26, *) {
            Circle().fill(.clear).glassEffect(in: Circle())
        } else {
            Circle().fill(.ultraThinMaterial)
                .overlay(Circle().fill(Color.white.opacity(0.25)))
                .overlay(Circle().strokeBorder(Color.white.opacity(0.5), lineWidth: 0.5))
        }
    }
}

// MARK: - Preview

#Preview {
    RootTabView()
}
