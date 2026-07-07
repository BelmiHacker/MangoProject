import SwiftUI

// NOTE: A native TabView is the strictest HIG-compliant choice and provides
// automatic state preservation, accessibility traits, and Catalyst support.
// This custom implementation is intentional to achieve the floating capsule
// visual design that a native TabView cannot produce.

struct RootTabView: View {
    @State private var selectedTab: RootTab = .home

    var body: some View {
        tabContentStack
            // safeAreaInset reserves space at the bottom so scrollable content
            // never hides under the floating bar without any per-view padding.
            .safeAreaInset(edge: .bottom, spacing: 0) {
                floatingBar
            }
    }

    /// Intercepts tab selection so tapping Scan is a no-op.
    /// The button remains visible but the tab never becomes active.
    private var tabBinding: Binding<RootTab> {
        Binding(
            get: { selectedTab },
            set: { newTab in
                guard newTab != .scan else { return }
                selectedTab = newTab
            }
        )
    }
}

// MARK: - Private views

private extension RootTabView {

    /// Home and Profile are kept alive simultaneously to preserve state
    /// (scroll position, loaded data) across tab switches.
    /// Scan has no content — the button is reserved for future development.
    var tabContentStack: some View {
        ZStack {
            MainMapPageView()
                .opacity(selectedTab == .home ? 1 : 0)
                .allowsHitTesting(selectedTab == .home)
                .accessibilityHidden(selectedTab != .home)

            NavigationStack {
                ProfileView()
            }
            .opacity(selectedTab == .profile ? 1 : 0)
            .allowsHitTesting(selectedTab == .profile)
            .accessibilityHidden(selectedTab != .profile)
        }
    }

    var floatingBar: some View {
        FloatingTabBar(
            selectedTab: tabBinding,
            onSearchTap: {}
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        // Transparent background so the floating capsule sits above the
        // content without an opaque inset backdrop.
        .background(Color.clear)
    }
}

// MARK: - Preview

#Preview {
    RootTabView()
}
