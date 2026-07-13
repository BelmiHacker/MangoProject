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

        guard latestLocation.horizontalAccuracy >= 0 else {
            return
        }

        // How long since our last accepted fix. Indoors (malls block GPS),
        // accuracy can stay above the "good" threshold indefinitely — if we
        // only ever accept great fixes, `location` freezes forever and the
        // distance readout never moves even though the user is walking.
        let staleness = location.map { abs($0.timestamp.timeIntervalSinceNow) } ?? .infinity
        let isStale = staleness > 8

        // A reading this poor (100s/1000s of meters) is a last-resort
        // cell/wifi estimate, not a real fix — never accept those, even
        // when stale, since they'd make the distance jump wildly instead
        // of just being frozen.
        guard latestLocation.horizontalAccuracy <= 300 else {
            return
        }

        let isAccurateEnough = latestLocation.horizontalAccuracy <= 80

        guard isAccurateEnough || isStale else {
            return
        }

        // Only de-noise against the existing fix when we're not stale —
        // once stale, any usable reading is better than staying frozen.
        if !isStale, let existing = location {
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
