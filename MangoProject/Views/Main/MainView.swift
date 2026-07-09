//
//  MainView.swift
//  MangoProject
//
//  Created by Muthiara Putri Aliyu on 09/07/26.

//
//  MainView.swift
//  MangoProject
//
//  Views/Main
//

import SwiftUI

/// The Home screen of Mango. Owns a MainViewModel and assembles the
/// header, points card, and restaurant sections into a single scrollable layout.
///
/// This view is intentionally "dumb" — it reads state from MainViewModel
/// and renders it, without containing any business logic itself.
struct MainView: View {
    @State private var viewModel: MainViewModel

    /// Accepts an optional pre-configured view model, primarily so previews
    /// and future tests can inject specific states (e.g. with recent searches
    /// already populated) instead of always starting from defaults.
    init(viewModel: MainViewModel = MainViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.section) {
                GreetingHeaderView(
                    userName: viewModel.userName,
                    onProfileTapped: {
                        // TODO: wire up navigation to Profile once routing is decided.
                    }
                )

                PointsCardView(points: viewModel.userPoints)

                if viewModel.hasRecentSearches {
                    RecentSearchSectionView(places: viewModel.recentSearches)
                }

                RecommendedSectionView(
                    places: viewModel.recommendedPlaces,
                    onBookmarkTapped: { place in
                        viewModel.toggleBookmark(for: place)
                    }
                )
            }
            .padding(Spacing.medium)
        }
        .background(Color("AppBackground"))
    }
}

#Preview("Default state") {
    MainView()
}

#Preview("After use — with recent searches") {
    let viewModel = MainViewModel()
    viewModel.recentSearches = RestaurantCardDisplayModel.mockList
    return MainView(viewModel: viewModel)
}
