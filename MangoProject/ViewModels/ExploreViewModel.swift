//
//  ExploreViewModel.swift
//  MangoProject
//

import Combine
import CoreLocation
import MapKit
import SwiftUI

@MainActor
final class ExploreViewModel: ObservableObject {

    // MARK: - Published UI State

    @Published var searchText = ""
    @Published var selectedCategory = "All"
    @Published var cameraPosition: MapCameraPosition

    // MARK: - Constants

    let categories = ["Cafe", "Bakery", "Indonesian", "Chinese"]

    // MARK: - Dependencies

    let locationManager = AppLocationManager()
    private let placesModel = MainMapViewModel()

    // MARK: - Internal State

    private(set) var mapRegion: MKCoordinateRegion
    private var hasCenteredOnUser = false
    private var cancellables = Set<AnyCancellable>()

    private static let defaultRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -6.2088, longitude: 106.8456),
        latitudinalMeters: 800,
        longitudinalMeters: 800
    )

    // MARK: - Derived Data

    var places: [NearbyFoodPlace] { placesModel.places }
    var isSearching: Bool { placesModel.isSearching }

    var filteredPlaces: [NearbyFoodPlace] {
        placesModel.places.filter { place in
            let matchesSearch = searchText.isEmpty
                || place.name.localizedCaseInsensitiveContains(searchText)
                || place.category.localizedCaseInsensitiveContains(searchText)
            let matchesCategory = selectedCategory == "All"
                || place.category.localizedCaseInsensitiveContains(selectedCategory)
            return matchesSearch && matchesCategory
        }
    }

    var headingDegrees: CLLocationDirection? {
        guard let heading = locationManager.heading else { return nil }
        return heading.trueHeading >= 0 ? heading.trueHeading : heading.magneticHeading
    }

    // MARK: - Init

    init() {
        cameraPosition = .region(Self.defaultRegion)
        mapRegion = Self.defaultRegion

        locationManager.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.objectWillChange.send() }
            .store(in: &cancellables)

        placesModel.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }

    // MARK: - Actions

    func onAppear() {
        locationManager.requestAccessAndStart()
    }

    func onCameraChange(_ context: MapCameraUpdateContext) {
        mapRegion = context.region
    }

    func onLocationUpdate(_ newLocation: CLLocation) async {
        guard !hasCenteredOnUser else { return }
        let region = MKCoordinateRegion(
            center: newLocation.coordinate,
            latitudinalMeters: 800,
            longitudinalMeters: 800
        )
        cameraPosition = .region(region)
        mapRegion = region
        hasCenteredOnUser = true
        await refreshPlaces()
    }

    func refreshPlaces() async {
        await placesModel.refreshPlaces(in: mapRegion, userLocation: locationManager.location)
    }

    func selectCategory(_ category: String) {
        withAnimation(.spring(response: 0.28, dampingFraction: 0.7)) {
            selectedCategory = selectedCategory == category ? "All" : category
        }
    }

    func clearSearch() {
        searchText = ""
    }
}
