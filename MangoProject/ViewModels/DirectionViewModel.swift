//
//  DirectionViewModel.swift
//  MangoProject
//

import Combine
import CoreLocation
import MapKit
import SwiftUI

@MainActor
final class DirectionViewModel: ObservableObject {

    // MARK: - Published State

    @Published var route: MKRoute?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var cameraPosition: MapCameraPosition
    @Published private(set) var mapHeading: CLLocationDirection = 0

    // MARK: - Dependencies

    let destination: NearbyFoodPlace
    let locationManager: AppLocationManager

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init(destination: NearbyFoodPlace, locationManager: AppLocationManager) {
        self.destination = destination
        self.locationManager = locationManager
        self.cameraPosition = .region(MKCoordinateRegion(
            center: destination.coordinate,
            latitudinalMeters: 1200,
            longitudinalMeters: 1200
        ))

        locationManager.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }

    // MARK: - Derived Data

    var headingDegrees: CLLocationDirection? {
        guard let heading = locationManager.heading else { return nil }
        return heading.trueHeading >= 0 ? heading.trueHeading : heading.magneticHeading
    }

    var steps: [MKRoute.Step] {
        route?.steps.filter { !$0.instructions.isEmpty } ?? []
    }

    /// Straight-line distance to the destination, used whenever MapKit
    /// couldn't calculate a formal walking route (e.g. dense food-stall
    /// areas or paths Apple's map data doesn't cover) — we still know
    /// roughly how far and how long it'll take, so navigation isn't blocked.
    private var straightLineDistanceMeters: CLLocationDistance? {
        guard let userLocation = locationManager.location else { return nil }
        let destinationLocation = CLLocation(
            latitude: destination.coordinate.latitude,
            longitude: destination.coordinate.longitude
        )
        return userLocation.distance(from: destinationLocation)
    }

    /// Average walking speed (~4.9 km/h) used to estimate travel time when
    /// there's no route to read `expectedTravelTime` from.
    private var estimatedWalkingSeconds: TimeInterval? {
        guard let straightLineDistanceMeters else { return nil }
        return straightLineDistanceMeters / 1.35
    }

    var durationText: String {
        let seconds: TimeInterval
        if let route {
            seconds = route.expectedTravelTime
        } else if let estimatedWalkingSeconds {
            seconds = estimatedWalkingSeconds
        } else {
            return "--"
        }

        let minutes = Int(seconds / 60)
        guard minutes >= 60 else { return "\(minutes) min" }
        let h = minutes / 60
        let m = minutes % 60
        return m == 0 ? "\(h) hr" : "\(h) hr \(m) min"
    }

    var distanceText: String {
        let m: CLLocationDistance
        if let route {
            m = route.distance
        } else if let straightLineDistanceMeters {
            m = straightLineDistanceMeters
        } else {
            return "--"
        }
        return m >= 1000 ? String(format: "%.1f km", m / 1000) : "\(Int(m.rounded())) m"
    }

    var etaText: String {
        let seconds: TimeInterval
        if let route {
            seconds = route.expectedTravelTime
        } else if let estimatedWalkingSeconds {
            seconds = estimatedWalkingSeconds
        } else {
            return "--"
        }

        let eta = Date.now.addingTimeInterval(seconds)
        return eta.formatted(date: .omitted, time: .shortened)
    }

    // MARK: - Actions

    func onCameraChange(_ context: MapCameraUpdateContext) {
        mapHeading = context.camera.heading
    }

    func fetchRoute() async {
        isLoading = true
        errorMessage = nil

        let request = MKDirections.Request()
        request.transportType = .walking
        request.source = MKMapItem.forCurrentLocation()

        if #available(iOS 26, *) {
            request.destination = MKMapItem(
                location: CLLocation(
                    latitude: destination.coordinate.latitude,
                    longitude: destination.coordinate.longitude
                ),
                address: nil
            )
        } else {
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination.coordinate))
        }

        do {
            let response = try await MKDirections(request: request).calculate()
            route = response.routes.first
            fitCameraToRoute()
        } catch {
            errorMessage = "Could not find a walking route."
        }

        isLoading = false
    }

    private func fitCameraToRoute() {
        guard let route else { return }
        var rect = route.polyline.boundingMapRect

        // Include user's actual GPS position so blue dot is always in frame
        if let userCoord = locationManager.location?.coordinate {
            let userPoint = MKMapPoint(userCoord)
            let userRect = MKMapRect(x: userPoint.x - 1, y: userPoint.y - 1, width: 2, height: 2)
            rect = rect.union(userRect)
        }

        let expanded = rect.insetBy(dx: -rect.width * 0.25, dy: -rect.height * 0.35)
        cameraPosition = .rect(expanded)
    }
}
