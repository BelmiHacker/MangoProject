//
//  ExplorePageView.swift
//  MangoProject
//

import Combine
import MapKit
import SwiftUI

struct ExplorePageView: View {

    @StateObject private var viewModel = ExploreViewModel()
    @State private var isSheetPresented = false
    @State private var selectedPlace: NearbyFoodPlace?

    private let regionRefreshTimer = Timer.publish(every: 2.5, on: .main, in: .common).autoconnect()

    var body: some View {
        Map(position: $viewModel.cameraPosition) {
            ForEach(viewModel.places) { place in
                Annotation("", coordinate: place.coordinate, anchor: .center) {
                    FoodMapPin(isFocused: false)
                }
            }
            if let coord = viewModel.locationManager.location?.coordinate {
                Annotation("", coordinate: coord, anchor: .center) {
                    UserHeadingMarker(headingDegrees: viewModel.headingDegrees)
                        .allowsHitTesting(false)
                }
            }
        }
        .onMapCameraChange { viewModel.onCameraChange($0) }
        .ignoresSafeArea()
        .onAppear { isSheetPresented = true }
        .sheet(isPresented: $isSheetPresented) {
            ExploreSheetContent(
                searchText: $viewModel.searchText,
                selectedCategory: $viewModel.selectedCategory,
                categories: viewModel.categories,
                places: viewModel.filteredPlaces,
                isSearching: viewModel.isSearching,
                onSelectCategory: viewModel.selectCategory,
                onClearSearch: viewModel.clearSearch,
                onDirections: { selectedPlace = $0 }
            )
            .interactiveDismissDisabled(true)
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .presentationBackgroundInteraction(.enabled)
        }
        .fullScreenCover(item: $selectedPlace) { place in
            FindingExperienceView(
                targetName: place.name,
                targetDistanceText: place.distanceText,
                targetCategory: place.category,
                targetLocationName: "Apple Maps",
                targetAddressLines: place.addressLines,
                targetCoordinate: place.coordinate,
                locationManager: viewModel.locationManager
            )
        }
        .onAppear { viewModel.onAppear() }
        .onReceive(viewModel.locationManager.$location.compactMap { $0 }) { location in
            Task { await viewModel.onLocationUpdate(location) }
        }
        .onReceive(regionRefreshTimer) { _ in
            Task { await viewModel.refreshPlaces() }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
