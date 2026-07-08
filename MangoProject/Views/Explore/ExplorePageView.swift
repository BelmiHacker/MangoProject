//
//  ExplorePageView.swift
//  MangoProject
//

import Combine
import MapKit
import SwiftUI

struct ExplorePageView: View {

    let onBack: () -> Void

    @StateObject private var viewModel = ExploreViewModel()
    @State private var isSheetPresented = false
    @State private var sheetDetent: PresentationDetent = .medium
    @State private var selectedPlace: NearbyFoodPlace?
    @State private var detailedPlace: NearbyFoodPlace?

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
                        .rotationEffect(.degrees(-viewModel.mapHeading))
                        .allowsHitTesting(false)
                }
            }
        }
        .onMapCameraChange(frequency: .continuous) { viewModel.onCameraChange($0) }
        .ignoresSafeArea()
        .overlay {
            backButtonOverlay
        }
        .onAppear {
            isSheetPresented = true
            viewModel.onAppear()
        }
        .sheet(isPresented: $isSheetPresented) {
            ExploreSheetContent(
                searchText: $viewModel.searchText,
                selectedCategories: $viewModel.selectedCategories,
                categories: viewModel.categories,
                places: viewModel.filteredPlaces,
                isSearching: viewModel.isSearching,
                onSelectCategory: viewModel.selectCategory,
                onClearSearch: viewModel.clearSearch,
                onDirections: { selectedPlace = $0 },
                onSelect: { detailedPlace = $0 }
            )
            .fullScreenCover(item: $selectedPlace) { place in
                DirectionPageView(place: place, locationManager: viewModel.locationManager)
            }
            .fullScreenCover(item: $detailedPlace) { place in
                RestaurantDetailView(place: place)
            }
            .interactiveDismissDisabled(true)
            .presentationDetents([.medium, .large], selection: $sheetDetent)
            .presentationDragIndicator(.visible)
            .presentationBackgroundInteraction(.enabled)
            .presentationBackground(.clear)
            .presentationCornerRadius(28)
        }
        .onReceive(viewModel.locationManager.$location.compactMap { $0 }) { location in
            Task { await viewModel.onLocationUpdate(location) }
        }
        .onReceive(regionRefreshTimer) { _ in
            Task { await viewModel.refreshPlaces() }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Back Button

    private var backButtonOverlay: some View {
        VStack {
            HStack {
                Button(action: onBack) {
                    ZStack {
                        if #available(iOS 26, *) {
                            Circle()
                                .fill(.clear)
                                .glassEffect(in: Circle())
                        } else {
                            Circle()
                                .fill(.ultraThinMaterial)
                        }
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.primary)
                    }
                    .frame(width: 52, height: 52)
                }
                .buttonStyle(.plain)
                .contentShape(Circle())
                .padding(.leading, 16)
                .padding(.top, 8)

                Spacer()
            }
            Spacer()
        }
    }

}
