//
//  MainMapPageView.swift
//  MangoProject
//
//  Created by Belmiro Kayru on 05/07/26.
//

import Combine
import CoreLocation
import MapKit
import SwiftUI

enum NavigationDest: Hashable {
    case finding(NearbyFoodPlace)
    case detail(NearbyFoodPlace)
}

struct MainMapPageView: View {
    // MARK: - State

    @StateObject private var locationManager = AppLocationManager()
    @StateObject private var viewModel = MainMapViewModel()
    @State private var navigationPath: [NavigationDest] = []
    @State private var focusedPlaceID: NearbyFoodPlace.ID?
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -6.2088, longitude: 106.8456),
        latitudinalMeters: 400,
        longitudinalMeters: 400
    )
    @State private var hasCenteredOnUser = false

    private let regionRefreshTimer = Timer.publish(every: 2.5, on: .main, in: .common).autoconnect()

    // MARK: - Body

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollViewReader { scrollProxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        heroSection
                            .padding(.horizontal, 20)
                        locationStatusCard
                            .padding(.horizontal, 20)
                        mapCard(scrollProxy: scrollProxy)
                            .padding(.horizontal, 20)
                        placesSection
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 36)
                }
                .background(pageBackground)
                .scrollIndicators(.visible)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                locationManager.requestAccessAndStart()
            }
            .onReceive(locationManager.$location.compactMap { $0 }) { newLocation in
                if !hasCenteredOnUser {
                    let region = mapRegion(center: newLocation.coordinate, radius: 200)
                    mapRegion = region
                    hasCenteredOnUser = true

                    Task {
                        await viewModel.refreshPlaces(in: region, userLocation: newLocation)
                    }
                }
            }
            .onReceive(regionRefreshTimer) { _ in
                Task {
                    await viewModel.refreshPlaces(in: mapRegion, userLocation: locationManager.location)
                }
            }
            .navigationDestination(for: NavigationDest.self) { dest in
                switch dest {
                case .finding(let place):
                    DirectionPageView(
                        place: place,
                        locationManager: locationManager
                    )
                case .detail(let place):
                    RestaurantDetailView(place: place)
                }
            }
        }
    }
}

private extension MainMapPageView {
    // MARK: - Sections

    var pageBackground: some View {
        Color(.systemGroupedBackground)
            .ignoresSafeArea()
    }

    var heroSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("HalalYuk")
                .font(.system(size: 50, weight: .bold))
                .foregroundStyle(.primary)

            Text("Nearby halal food, guided by GPS and compass.")
                .font(.system(size: 23, weight: .semibold))
                .foregroundStyle(.secondary)
                .lineSpacing(3)
        }
    }

    var locationStatusCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            StatusRow(systemImage: "safari.fill", text: headingText)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    func mapCard(scrollProxy: ScrollViewProxy) -> some View {
        ZStack(alignment: .bottomTrailing) {
            Map(
                coordinateRegion: $mapRegion,
                showsUserLocation: false,
                annotationItems: mapAnnotations
            ) { annotation in
                MapAnnotation(coordinate: annotation.coordinate, anchorPoint: CGPoint(x: 0.5, y: 0.5)) {
                    switch annotation {
                    case .user(_, let headingDegrees):
                        UserHeadingMarker(headingDegrees: headingDegrees)
                            .accessibilityLabel("Your location and direction")
                            .allowsHitTesting(false)
                    case .place(let place):
                        Button {
                            focus(place, scrollProxy: scrollProxy)
                        } label: {
                            FoodMapPin(isFocused: focusedPlaceID == place.id)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(place.name)
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))

            Button {
                if let location = locationManager.location {
                    withAnimation(.easeInOut(duration: 0.45)) {
                        mapRegion = mapRegion(center: location.coordinate, radius: 200)
                    }
                }
            } label: {
                Image(systemName: "location.fill")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.blue)
                    .frame(width: 74, height: 74)
                    .background(.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.18), radius: 12, y: 4)
            }
            .padding(20)
        }
        .frame(height: 352)
        .overlay(alignment: .bottomLeading) {
            Text("Apple Maps")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.regularMaterial)
                .clipShape(Capsule())
                .padding(14)
        }
    }

    var placesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(sectionTitle)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.primary)
                .padding(.horizontal, 20)

            if viewModel.isSearching && viewModel.places.isEmpty {
                LoadingPlaceCard()
                    .padding(.horizontal, 20)
            } else if let message = viewModel.errorMessage ?? locationManager.errorMessage, viewModel.places.isEmpty {
                MessageCard(text: message)
                    .padding(.horizontal, 20)
            } else if viewModel.places.isEmpty {
                MessageCard(text: "No nearby halal food results yet.")
                    .padding(.horizontal, 20)
            } else {
                if viewModel.isSearching {
                    Label("Updating this map area", systemImage: "arrow.triangle.2.circlepath")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 20)
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(viewModel.places.prefix(12)) { place in
                            FoodPlaceCard(
                                place: place,
                                isFocused: focusedPlaceID == place.id,
                                onFocus: {
                                    focus(place)
                                },
                                onNavigate: {
                                    navigationPath.append(.finding(place))
                                },
                                onSelectName: {
                                    navigationPath.append(.detail(place))
                                }
                            )
                            .frame(width: 300)
                            .id(place.id)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                }
            }
        }
    }

    // MARK: - Computed State

    var sectionTitle: String {
        if viewModel.isSearching {
            return "Searching visible places"
        }

        return "\(viewModel.places.count) visible places within \(viewModel.visibleRadiusText)"
    }

    var headingText: String {
        guard let headingDegrees else {
            return "Compass heading unavailable"
        }

        return "Compass heading: \(Int(headingDegrees.rounded())) degrees"
    }

    var mapAnnotations: [MainMapAnnotation] {
        var annotations = viewModel.places.map(MainMapAnnotation.place)

        if let location = locationManager.location {
            annotations.append(.user(location.coordinate, headingDegrees))
        }

        return annotations
    }

    var headingDegrees: CLLocationDirection? {
        guard let heading = locationManager.heading else {
            return nil
        }

        if heading.trueHeading >= 0 {
            return heading.trueHeading
        }

        return heading.magneticHeading
    }

    // MARK: - Actions

    func mapRegion(center: CLLocationCoordinate2D, radius: CLLocationDistance) -> MKCoordinateRegion {
        MKCoordinateRegion(
            center: center,
            latitudinalMeters: radius * 2,
            longitudinalMeters: radius * 2
        )
    }

    func focus(_ place: NearbyFoodPlace, scrollProxy: ScrollViewProxy? = nil) {
        focusedPlaceID = place.id

        withAnimation(.easeInOut(duration: 0.35)) {
            mapRegion = MKCoordinateRegion(
                center: place.coordinate,
                span: mapRegion.span
            )
        }

        if let scrollProxy {
            withAnimation(.snappy) {
                scrollProxy.scrollTo(place.id, anchor: .center)
            }
        }
    }
}

#Preview {
    MainMapPageView()
}

