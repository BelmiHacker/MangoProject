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

struct MainMapPageView: View {
    // MARK: - State

    @StateObject private var locationManager = AppLocationManager()
    @StateObject private var viewModel = MainMapViewModel()
    @State private var navigationPath: [NearbyFoodPlace] = []
    @State private var focusedPlaceID: NearbyFoodPlace.ID?
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -6.2088, longitude: 106.8456),
        latitudinalMeters: 400,
        longitudinalMeters: 400
    )
    @State private var hasCenteredOnUser = false
    @State private var cameraPosition: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -6.2088, longitude: 106.8456),
        latitudinalMeters: 400,
        longitudinalMeters: 400
    ))

    private let regionRefreshTimer = Timer.publish(every: 2.5, on: .main, in: .common).autoconnect()

    // MARK: - Body

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollViewReader { scrollProxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 26) {
                        heroSection
                        locationStatusCard
                        mapCard(scrollProxy: scrollProxy)
                        placesSection
                    }
                    .padding(.horizontal, 20)
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
                    cameraPosition = .region(region)
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
            .navigationDestination(for: NearbyFoodPlace.self) { place in
                FindingExperienceView(
                    targetName: place.name,
                    targetDistanceText: place.distanceText,
                    targetCategory: place.category,
                    targetLocationName: "Apple Maps",
                    targetAddressLines: place.addressLines,
                    targetCoordinate: place.coordinate,
                    locationManager: locationManager
                )
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
            Map(position: $cameraPosition) {
                ForEach(viewModel.places) { place in
                    Annotation("", coordinate: place.coordinate, anchor: .center) {
                        Button {
                            focus(place, scrollProxy: scrollProxy)
                        } label: {
                            FoodMapPin(isFocused: focusedPlaceID == place.id)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(place.name)
                    }
                }
                if let userCoord = locationManager.location?.coordinate {
                    Annotation("", coordinate: userCoord, anchor: .center) {
                        UserHeadingMarker(headingDegrees: headingDegrees)
                            .accessibilityLabel("Your location and direction")
                            .allowsHitTesting(false)
                    }
                }
            }
            .onMapCameraChange { context in
                mapRegion = context.region
            }
            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))

            Button {
                if let location = locationManager.location {
                    let region = mapRegion(center: location.coordinate, radius: 200)
                    withAnimation(.easeInOut(duration: 0.45)) {
                        cameraPosition = .region(region)
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
        VStack(alignment: .leading, spacing: 18) {
            Text(sectionTitle)
                .font(.system(size: 27, weight: .bold))
                .foregroundStyle(.primary)

            if viewModel.isSearching && viewModel.places.isEmpty {
                LoadingPlaceCard()
            } else if let message = viewModel.errorMessage ?? locationManager.errorMessage, viewModel.places.isEmpty {
                MessageCard(text: message)
            } else if viewModel.places.isEmpty {
                MessageCard(text: "No nearby halal food results yet.")
            } else {
                if viewModel.isSearching {
                    Label("Updating this map area", systemImage: "arrow.triangle.2.circlepath")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.secondary)
                }

                ForEach(viewModel.places.prefix(12)) { place in
                    FoodPlaceCard(
                        place: place,
                        isFocused: focusedPlaceID == place.id,
                        onFocus: {
                            focus(place)
                        },
                        onNavigate: {
                            navigationPath.append(place)
                        },
                        onSelectName: {
                                    // Tulis logic atau *action* saat nama di-klik di sini,
                                    // atau biarkan kosong `{}` dulu agar proyek lu bisa sukses compile.
                                    print("Nama tempat diklik: \(place.name)")
                                }
                    )
                    .id(place.id)
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
            cameraPosition = .region(MKCoordinateRegion(
                center: place.coordinate,
                span: mapRegion.span
            ))
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
