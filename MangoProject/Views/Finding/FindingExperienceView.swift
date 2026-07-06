//
//  FindingExperienceView.swift
//  MangoProject
//
//  Created by Belmiro Kayru on 04/07/26.
//

import Combine
import CoreLocation
import SwiftUI

struct FindingExperienceView: View {
    let targetName: String
    let targetDistanceText: String
    let targetCategory: String
    let targetLocationName: String
    let targetAddressLines: [String]
    let targetCoordinate: CLLocationCoordinate2D?

    private let compactDetent = PresentationDetent.height(128)
    private let mediumDetent = PresentationDetent.fraction(0.52)

    @StateObject private var locationManager = AppLocationManager()
    @State private var isPlaceSheetPresented = true
    @State private var placeSheetDetent: PresentationDetent = .height(128)
    @State private var simulatedStepProgress = 0

    private let movementTimer = Timer.publish(every: 1.4, on: .main, in: .common).autoconnect()

    init(
        targetName: String = "Tamper Coffee",
        targetDistanceText: String = "150 m",
        targetCategory: String = "Coffee Shop",
        targetLocationName: String = "The Breeze",
        targetAddressLines: [String] = ["Sampora", "Tangerang", "Banten", "Indonesia"],
        targetCoordinate: CLLocationCoordinate2D? = nil
    ) {
        self.targetName = targetName
        self.targetDistanceText = targetDistanceText
        self.targetCategory = targetCategory
        self.targetLocationName = targetLocationName
        self.targetAddressLines = targetAddressLines
        self.targetCoordinate = targetCoordinate
    }

    private var findingState: FindingNavigationState {
        FindingNavigationState(
            targetName: targetName,
            distanceText: liveDistanceText,
            directionPrefixText: "to your",
            directionFocusText: directionFocusText,
            arrowAngle: arrowDisplayAngle,
            instructionDistanceText: liveDistanceText,
            instructionText: instructionText,
            stepProgress: simulatedStepProgress,
            stepCount: 6
        )
    }

    private var placeDetailState: FindingPlaceDetailState {
        // Values mirror the Apple Maps screenshots used as the usability-testing reference.
        FindingPlaceDetailState(
            name: targetName,
            category: targetCategory,
            locationName: targetLocationName,
            websiteText: "instagram.com/tampercoffeejkt",
            hoursStatus: "Open",
            hoursText: "07.00 - 22.00",
            distanceText: liveDistanceText,
            addressLines: targetAddressLines
        )
    }

    var body: some View {
        FindingNavigationView(state: findingState)
            .onAppear {
                locationManager.requestAccessAndStart()
            }
            .onReceive(movementTimer) { _ in
                updateProgress()
            }
            .sheet(isPresented: $isPlaceSheetPresented) {
                sheetContent
                    .presentationDetents([compactDetent, mediumDetent, .large], selection: $placeSheetDetent)
                    .presentationDragIndicator(.hidden)
                    .presentationCornerRadius(18)
                    .presentationBackground(.clear)
                    .presentationBackgroundInteraction(.enabled(upThrough: mediumDetent))
                    .interactiveDismissDisabled()
            }
    }
}

private extension FindingExperienceView {
    var userLocation: CLLocation? {
        locationManager.location
    }

    var headingDegrees: Double? {
        guard let heading = locationManager.heading else {
            return nil
        }

        if heading.trueHeading >= 0 {
            return heading.trueHeading
        }

        if heading.magneticHeading >= 0 {
            return heading.magneticHeading
        }

        return nil
    }

    var liveDistanceMeters: CLLocationDistance? {
        guard let userLocation, let targetCoordinate else {
            return nil
        }

        let targetLocation = CLLocation(
            latitude: targetCoordinate.latitude,
            longitude: targetCoordinate.longitude
        )

        return userLocation.distance(from: targetLocation)
    }

    var liveDistanceText: String {
        guard let liveDistanceMeters else {
            return targetDistanceText
        }

        if liveDistanceMeters >= 1_000 {
            return String(format: "%.1f km", liveDistanceMeters / 1_000)
        }

        return "\(Int(liveDistanceMeters.rounded())) m"
    }

    var relativeBearing: Double? {
        guard
            let userCoordinate = userLocation?.coordinate,
            let targetCoordinate,
            let headingDegrees
        else {
            return nil
        }

        let targetBearing = bearingDegrees(from: userCoordinate, to: targetCoordinate)
        return normalizedDegrees(targetBearing - headingDegrees)
    }

    var arrowDisplayAngle: Double {
        guard let relativeBearing else {
            return -45
        }

        // The symbol points right at 0 degrees, so subtract 90 to make 0 degrees mean straight ahead.
        return relativeBearing - 90
    }

    var directionFocusText: String {
        guard let relativeBearing else {
            return "ahead"
        }

        let absoluteBearing = abs(relativeBearing)

        if absoluteBearing <= 22.5 {
            return "ahead"
        } else if absoluteBearing >= 157.5 {
            return "behind"
        } else if relativeBearing > 0 {
            return "right"
        } else {
            return "left"
        }
    }

    var instructionText: String {
        guard targetCoordinate != nil else {
            return "Finding target"
        }

        if headingDegrees == nil {
            return "Move your iPhone to calibrate"
        }

        switch directionFocusText {
        case "ahead":
            return "Keep going straight"
        case "behind":
            return "Turn around"
        case "right":
            return "Move to your right"
        default:
            return "Move to your left"
        }
    }

    @ViewBuilder
    var sheetContent: some View {
        if placeSheetDetent == compactDetent {
            CompactPlaceSheetView(
                state: placeDetailState,
                onClose: closeSheet
            )
            .frame(maxHeight: .infinity, alignment: .bottom)
        } else {
            PlaceDetailSheetView(
                state: placeDetailState,
                onClose: closeSheet
            )
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }

    func closeSheet() {
        isPlaceSheetPresented = false
    }

    func updateProgress() {
        simulatedStepProgress = (simulatedStepProgress + 1) % 6
    }

    func bearingDegrees(
        from startCoordinate: CLLocationCoordinate2D,
        to endCoordinate: CLLocationCoordinate2D
    ) -> Double {
        let startLatitude = startCoordinate.latitude * .pi / 180
        let startLongitude = startCoordinate.longitude * .pi / 180
        let endLatitude = endCoordinate.latitude * .pi / 180
        let endLongitude = endCoordinate.longitude * .pi / 180
        let longitudeDelta = endLongitude - startLongitude

        let y = sin(longitudeDelta) * cos(endLatitude)
        let x = cos(startLatitude) * sin(endLatitude) -
            sin(startLatitude) * cos(endLatitude) * cos(longitudeDelta)
        let bearing = atan2(y, x) * 180 / .pi

        return (bearing + 360).truncatingRemainder(dividingBy: 360)
    }

    func normalizedDegrees(_ degrees: Double) -> Double {
        var normalized = degrees.truncatingRemainder(dividingBy: 360)

        if normalized > 180 {
            normalized -= 360
        } else if normalized < -180 {
            normalized += 360
        }

        return normalized
    }
}

#Preview {
    FindingExperienceView()
}
