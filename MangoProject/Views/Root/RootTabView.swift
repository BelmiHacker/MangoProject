import SwiftUI

struct RootTabView: View {
    @State private var selectedTab: RootTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(value: RootTab.home) {
                NavigationStack {
                    MainView(onNavigateToPoints: { selectedTab = .points })
                }
            } label: {
                Label(RootTab.home.label, systemImage: RootTab.home.icon)
            }

            Tab(value: RootTab.explore) {
                NavigationStack {
                    ExplorePageView(onBack: { selectedTab = .home })
                }
                .toolbar(.hidden, for: .tabBar)
            } label: {
                Label(RootTab.explore.label, systemImage: RootTab.explore.icon)
            }

            Tab(value: RootTab.foodDNA) {
                NavigationStack {
                    FoodDNAView()
                }
            } label: {
                Label(RootTab.foodDNA.label, systemImage: RootTab.foodDNA.icon)
            }

            Tab(value: RootTab.points) {
                NavigationStack {
                    PointsPageView()
                }
            } label: {
                Label(RootTab.points.label, systemImage: RootTab.points.icon)
            }
        }
        .tint(Color("Accent"))
    }
}

// MARK: - Preview

#Preview {
    RootTabView()
}
