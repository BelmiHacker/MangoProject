//
//  AppLocationManager.swift
//  MangoProject
//
//  Created by Belmiro Kayru on 05/07/26.
//

import Combine
import CoreLocation
import Foundation

final class AppLocationManager: NSObject, ObservableObject {
    @Published private(set) var authorizationStatus: CLAuthorizationStatus
    @Published private(set) var location: CLLocation?
    @Published private(set) var heading: CLHeading?
    @Published private(set) var errorMessage: String?

    private let locationManager = CLLocationManager()

    override init() {
        authorizationStatus = .notDetermined
        super.init()

        authorizationStatus = locationManager.authorizationStatus
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.headingFilter = 1
        locationManager.activityType = .fitness
        locationManager.pausesLocationUpdatesAutomatically = false
    }

    func requestAccessAndStart() {
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            startUpdates()
        case .denied, .restricted:
            errorMessage = "Location permission is not available."
        @unknown default:
            errorMessage = "Unknown location permission status."
        }
    }

    func startUpdates() {
        locationManager.startUpdatingLocation()

        if CLLocationManager.headingAvailable() {
            locationManager.startUpdatingHeading()
        }
    }

    func requestCurrentLocation() {
        guard authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse else {
            return
        }

        locationManager.requestLocation()
    }
}

extension AppLocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus

        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            startUpdates()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.last else {
            return
        }

        let locationAge = abs(latestLocation.timestamp.timeIntervalSinceNow)
        guard locationAge < 10 else {
            return
        }

        // Reject readings with poor accuracy — this is the main cause of
        // the distance jumping when GPS signal is weak. A reading with
        // horizontalAccuracy > 80m means the coordinate could be off by
        // up to 80m from the real position, which makes distance calculations
        // wildly unreliable. We freeze the last good value instead.
        guard latestLocation.horizontalAccuracy >= 0,
              latestLocation.horizontalAccuracy <= 80 else {
            return
        }

        // Only update if the new reading is meaningfully better or different
        if let existing = location {
            let isMoreAccurate = latestLocation.horizontalAccuracy < existing.horizontalAccuracy
            let hasMoved = latestLocation.distance(from: existing) > 2
            guard isMoreAccurate || hasMoved else {
                return
            }
        }

        location = latestLocation
        errorMessage = nil
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        heading = newHeading
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let locationError = error as? CLError, locationError.code == .locationUnknown {
            return
        }

        errorMessage = error.localizedDescription
    }
}
