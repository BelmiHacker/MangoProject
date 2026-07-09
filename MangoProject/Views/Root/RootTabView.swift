import SwiftUI

struct RootTabView: View {
    @State private var selectedTab: RootTab = .home

    var body: some View {
        tabContentStack
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if selectedTab != .explore {
                    FloatingTabBar(selectedTab: $selectedTab)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                        .background(Color.clear)
                }
            }
    }
}

// MARK: - Content Stack

private extension RootTabView {
    var tabContentStack: some View {
        ZStack {
            MainView()
                .opacity(selectedTab == .home ? 1 : 0)
                .allowsHitTesting(selectedTab == .home)
                .accessibilityHidden(selectedTab != .home)

            if selectedTab == .explore {
                NavigationStack { ExplorePageView(onBack: { selectedTab = .home }) }
                    .transition(.opacity)
            }

            NavigationStack { FoodDNAPageView() }
                .opacity(selectedTab == .foodDNA ? 1 : 0)
                .allowsHitTesting(selectedTab == .foodDNA)
                .accessibilityHidden(selectedTab != .foodDNA)

            NavigationStack { PointsPageView() }
                .opacity(selectedTab == .points ? 1 : 0)
                .allowsHitTesting(selectedTab == .points)
                .accessibilityHidden(selectedTab != .points)
        }
        .animation(.easeInOut(duration: 0.2), value: selectedTab)
    }
}

// MARK: - Placeholder pages (replace when feature pages are ready)

struct FoodDNAPageView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "fork.knife")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("Food DNA")
                .font(.title2.bold())
            Text("Coming soon")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
    }
}

// MARK: - Preview

#Preview {
    RootTabView()
}
