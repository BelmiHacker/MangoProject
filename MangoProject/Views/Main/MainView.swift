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
    var pointsStore: UserPointsStore
    @State private var showingProfile = false
    @State private var isNFCScanPresented = false

    var onNavigateToPoints: (() -> Void)? = nil

    /// Accepts an optional pre-configured view model, primarily so previews
    /// and future tests can inject specific states (e.g. with recent searches
    /// already populated) instead of always starting from defaults.
    init(
        viewModel: MainViewModel = MainViewModel(),
        pointsStore: UserPointsStore = UserPointsStore(),
        onNavigateToPoints: (() -> Void)? = nil
    ) {
        _viewModel = State(initialValue: viewModel)
        self.pointsStore = pointsStore
        self.onNavigateToPoints = onNavigateToPoints
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.section) {
                GreetingHeaderView(
                    userName: viewModel.userName,
                    onProfileTapped: {
                        showingProfile = true
                    }
                )

                PointsCardView(
                    points: pointsStore.points,
                    onTapToCollect: { isNFCScanPresented = true }
                )

                OffersSectionView()

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
        .navigationDestination(isPresented: $showingProfile) {
            ProfileView(onNavigateToPoints: {
                // First dismiss the profile view, then switch tabs
                showingProfile = false
                onNavigateToPoints?()
            })
        }
        .navigationDestination(for: NearbyFoodPlace.self) { place in
            RestaurantDetailView(place: place)
                .navigationBarBackButtonHidden(true)
        }
        .sheet(isPresented: $isNFCScanPresented) {
            NFCScanSheet(
                onCancel: { isNFCScanPresented = false },
                onSuccess: {
                    pointsStore.points += 500
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        isNFCScanPresented = false
                    }
                }
            )
            .presentationDetents([.height(480)])
            .presentationDragIndicator(.hidden)
            .presentationCornerRadius(28)
            .presentationBackground(.clear)
        }
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
