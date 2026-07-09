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
    @State private var focusedPlace: NearbyFoodPlace?

    private let regionRefreshTimer = Timer.publish(every: 2.5, on: .main, in: .common).autoconnect()
    private let focusedDetent = PresentationDetent.height(300)
    private let compactDetent = PresentationDetent.height(80)

    var body: some View {
        Map(position: $viewModel.cameraPosition) {
            ForEach(viewModel.places) { place in
                Annotation("", coordinate: place.coordinate, anchor: .center) {
                    FoodMapPin(isFocused: focusedPlace?.id == place.id)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                if focusedPlace?.id == place.id {
                                    focusedPlace = nil
                                } else {
                                    focusedPlace = place
                                    viewModel.focusOn(place: place)
                                }
                            }
                        }
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
        .onChange(of: focusedPlace) { _, newPlace in
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                sheetDetent = newPlace != nil ? focusedDetent : .medium
            }
        }
        .sheet(isPresented: $isSheetPresented) {
            Group {
                if let place = focusedPlace {
                    ExplorePlaceCard(
                        place: place,
                        onClose: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                focusedPlace = nil
                            }
                        },
                        onDirections: {
                            selectedPlace = place
                        }
                    )
                } else {
                    ExploreSheetContent(
                        searchText: $viewModel.searchText,
                        selectedCategories: $viewModel.selectedCategories,
                        categories: viewModel.categories,
                        places: viewModel.filteredPlaces,
                        isSearching: viewModel.isSearching,
                        isCompact: sheetDetent == compactDetent,
                        onSelectCategory: viewModel.selectCategory,
                        onClearSearch: viewModel.clearSearch,
                        onDirections: { selectedPlace = $0 },
                        onSelect: { detailedPlace = $0 }
                    )
                }
            }
            .fullScreenCover(item: $selectedPlace) { place in
                DirectionPageView(place: place, locationManager: viewModel.locationManager)
            }
            .fullScreenCover(item: $detailedPlace) { place in
                RestaurantDetailView(place: place)
            }
            .interactiveDismissDisabled(true)
            .presentationDetents(
                focusedPlace != nil ? [focusedDetent] : [compactDetent, .medium, .large],
                selection: $sheetDetent
            )
            .presentationDragIndicator(focusedPlace != nil ? .hidden : .visible)
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
