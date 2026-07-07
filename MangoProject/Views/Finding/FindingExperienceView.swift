//
//  FindingExperienceView.swift
//  MangoProject
//
//  Created by Belmiro Kayru on 04/07/26.
//

import Combine
import CoreLocation
import MapKit
import SwiftUI

struct FindingExperienceView: View {
    @Environment(\.dismiss) private var dismiss

    let targetName: String
    let targetDistanceText: String
    let targetCategory: String
    let targetLocationName: String
    let targetAddressLines: [String]
    let targetCoordinate: CLLocationCoordinate2D?

    private let compactDetent = PresentationDetent.height(104)
    private let mediumDetent = PresentationDetent.fraction(0.52)

    @ObservedObject private var locationManager: AppLocationManager
    @State private var isPlaceSheetPresented = true
    @State private var placeSheetDetent: PresentationDetent = .height(104)
    @State private var displayedDistanceMeters: CLLocationDistance?
    @State private var routeCoordinates: [CLLocationCoordinate2D] = []
    @State private var routeInstructions: [RouteInstruction] = []
    @State private var routeOrigin: CLLocationCoordinate2D?
    @State private var isLoadingRoute = false
    @State private var lastRouteAttemptDate: Date?
    @State private var lastRouteAttemptOrigin: CLLocationCoordinate2D?

    private let distanceSmoothingTimer = Timer.publish(every: 0.08, on: .main, in: .common).autoconnect()

    init(
        targetName: String = "Tamper Coffee",
        targetDistanceText: String = "150 m",
        targetCategory: String = "Coffee Shop",
        targetLocationName: String = "The Breeze",
        targetAddressLines: [String] = ["Sampora", "Tangerang", "Banten", "Indonesia"],
        targetCoordinate: CLLocationCoordinate2D? = nil,
        locationManager: AppLocationManager = AppLocationManager()
    ) {
        self.targetName = targetName
        self.targetDistanceText = targetDistanceText
        self.targetCategory = targetCategory
        self.targetLocationName = targetLocationName
        self.targetAddressLines = targetAddressLines
        self.targetCoordinate = targetCoordinate
        self.locationManager = locationManager
    }

    private var findingState: FindingNavigationState {
        FindingNavigationState(
            targetName: targetName,
            distanceText: displayedDistanceText,
            directionPrefixText: "to your",
            directionFocusText: directionFocusText,
            arrowAngle: arrowDisplayAngle,
            instructionDistanceText: displayedDistanceText,
            instructionText: instructionText,
            stepProgress: stepProgressIndex,
            stepCount: 6,
            proximityProgress: displayedProximityProgress
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
            distanceText: displayedDistanceText,
            addressLines: targetAddressLines
        )
    }

    var body: some View {
        FindingNavigationView(state: findingState)
            .onAppear {
                locationManager.requestAccessAndStart()
                initializeDisplayedDistance()
                refreshRouteIfNeeded(for: userLocation, force: true)
            }
            .onReceive(locationManager.$location) { location in
                refreshRouteIfNeeded(for: location)
            }
            .onReceive(distanceSmoothingTimer) { _ in
                updateDisplayedDistance()
            }
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .navigationBar)
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

        return formattedDistanceText(from: liveDistanceMeters)
    }

    var displayedDistanceText: String {
        guard let displayedDistanceMeters else {
            return liveDistanceText
        }

        return formattedDistanceText(from: displayedDistanceMeters)
    }

    var fallbackDistanceMeters: CLLocationDistance? {
        let lowercasedText = targetDistanceText.lowercased()
        let numericText = lowercasedText.filter { character in
            character.isNumber || character == "." || character == ","
        }
        .replacingOccurrences(of: ",", with: ".")

        guard let value = Double(numericText) else {
            return nil
        }

        if lowercasedText.contains("km") {
            return value * 1_000
        }

        return value
    }

    var targetDisplayDistanceMeters: CLLocationDistance? {
        liveDistanceMeters ?? fallbackDistanceMeters
    }

    var displayedProximityProgress: Double {
        guard let distance = displayedDistanceMeters ?? liveDistanceMeters else {
            return 0
        }

        let clampedDistance = min(max(distance, 0), 25)
        return 1 - (clampedDistance / 25)
    }

    func formattedDistanceText(from distance: CLLocationDistance) -> String {
        if distance >= 1_000 {
            return String(format: "%.1f km", distance / 1_000)
        }

        return "\(Int(distance.rounded())) m"
    }

    var proximityProgress: Double {
        guard let liveDistanceMeters else {
            return 0
        }

        let clampedDistance = min(max(liveDistanceMeters, 0), 25)
        return 1 - (clampedDistance / 25)
    }

    func initializeDisplayedDistance() {
        guard displayedDistanceMeters == nil else {
            return
        }

        displayedDistanceMeters = targetDisplayDistanceMeters
    }

    func updateDisplayedDistance() {
        // Only smooth toward a live GPS reading.
        // If GPS is temporarily unavailable, freeze the displayed value instead
        // of drifting back toward the initial text distance (fallbackDistanceMeters),
        // which caused the "stuck then sudden drop" behaviour.
        guard let targetDistance = liveDistanceMeters else {
            return
        }

        guard let currentDistance = displayedDistanceMeters else {
            displayedDistanceMeters = targetDistance
            return
        }

        let delta = targetDistance - currentDistance

        guard abs(delta) > 1 else {
            displayedDistanceMeters = targetDistance
            return
        }

        displayedDistanceMeters = currentDistance + (delta > 0 ? 1 : -1)
    }

    var relativeBearing: Double? {
        guard
            let destinationBearing,
            let headingDegrees
        else {
            return nil
        }

        return normalizedDegrees(destinationBearing - headingDegrees)
    }

    var destinationBearing: Double? {
        guard let userCoordinate = userLocation?.coordinate else {
            return nil
        }

        if routeCoordinates.count > 1,
           let routeBearing = routeBearing(from: userCoordinate) {
            return routeBearing
        }

        guard let targetCoordinate else {
            return nil
        }

        return bearingDegrees(from: userCoordinate, to: targetCoordinate)
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

    var stepProgressIndex: Int {
        guard routeInstructions.count > 1, let currentIndex = currentRouteInstructionIndex else {
            return 0
        }

        let progress = Double(currentIndex) / Double(max(routeInstructions.count - 1, 1))
        return min(max(Int((progress * 5).rounded()), 0), 5)
    }

    var instructionText: String {
        guard targetCoordinate != nil else {
            return "Finding target"
        }

        if let routeInstructionText {
            return routeInstructionText
        }

        if isLoadingRoute {
            return "Finding walking route"
        }

        if headingDegrees == nil {
            return "Calibrating compass"
        }

        return "Head toward \(targetName)"
    }

    var routeInstructionText: String? {
        guard
            let currentRouteInstructionIndex,
            routeInstructions.indices.contains(currentRouteInstructionIndex)
        else {
            return nil
        }

        return routeInstructions[currentRouteInstructionIndex].text
    }

    var currentRouteInstructionIndex: Int? {
        guard let userLocation, !routeInstructions.isEmpty else {
            return nil
        }

        for (index, instruction) in routeInstructions.enumerated() {
            guard let coordinate = instruction.endCoordinate else {
                continue
            }

            let stepEndLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            if userLocation.distance(from: stepEndLocation) > 12 {
                return index
            }
        }

        return routeInstructions.indices.last
    }

    func refreshRouteIfNeeded(for location: CLLocation?, force: Bool = false) {
        guard let origin = location?.coordinate, targetCoordinate != nil else {
            return
        }

        guard force || shouldRefreshRoute(from: origin) else {
            return
        }

        Task {
            await loadRoute(from: origin)
        }
    }

    func shouldRefreshRoute(from coordinate: CLLocationCoordinate2D) -> Bool {
        guard !isLoadingRoute else {
            return false
        }

        if routeCoordinates.count < 2 {
            return canAttemptRoute(from: coordinate)
        }

        guard let routeOrigin else {
            return true
        }

        let movedFromOrigin = CLLocation(latitude: routeOrigin.latitude, longitude: routeOrigin.longitude)
            .distance(from: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))

        guard movedFromOrigin >= 80 else {
            return false
        }

        if let projection = closestRouteProjection(to: coordinate),
           projection.distanceMeters <= 35 {
            return false
        }

        return canAttemptRoute(from: coordinate)
    }

    func canAttemptRoute(from coordinate: CLLocationCoordinate2D) -> Bool {
        guard let lastRouteAttemptDate, let lastRouteAttemptOrigin else {
            return true
        }

        let secondsSinceLastAttempt = Date().timeIntervalSince(lastRouteAttemptDate)
        let movedSinceLastAttempt = CLLocation(latitude: lastRouteAttemptOrigin.latitude, longitude: lastRouteAttemptOrigin.longitude)
            .distance(from: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))

        return secondsSinceLastAttempt >= 20 || movedSinceLastAttempt >= 25
    }

    @MainActor
    func loadRoute(from origin: CLLocationCoordinate2D) async {
        guard let targetCoordinate, !isLoadingRoute else {
            return
        }

        isLoadingRoute = true
        lastRouteAttemptDate = Date()
        lastRouteAttemptOrigin = origin

        do {
            let routeData = try await calculateRoute(from: origin, to: targetCoordinate)
            routeCoordinates = routeData.coordinates
            routeInstructions = routeData.instructions
            routeOrigin = origin
        } catch {
            routeCoordinates = []
            routeInstructions = []
            routeOrigin = nil
        }

        isLoadingRoute = false
    }

    func calculateRoute(
        from origin: CLLocationCoordinate2D,
        to destinationCoordinate: CLLocationCoordinate2D
    ) async throws -> RouteData {
        do {
            return try await calculateRoute(
                from: origin,
                to: destinationCoordinate,
                transportType: .walking
            )
        } catch {
            return try await calculateRoute(
                from: origin,
                to: destinationCoordinate,
                transportType: .automobile
            )
        }
    }

    func calculateRoute(
        from origin: CLLocationCoordinate2D,
        to destinationCoordinate: CLLocationCoordinate2D,
        transportType: MKDirectionsTransportType
    ) async throws -> RouteData {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: origin))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoordinate))
        request.transportType = transportType
        request.requestsAlternateRoutes = false

        let response = try await MKDirections(request: request).calculate()
        guard let route = response.routes.min(by: { $0.expectedTravelTime < $1.expectedTravelTime }) else {
            throw RouteError.noRoute
        }

        return RouteData(route: route, destinationName: targetName)
    }

    func routeBearing(from coordinate: CLLocationCoordinate2D) -> Double? {
        guard let projection = closestRouteProjection(to: coordinate),
              let lookaheadCoordinate = lookaheadCoordinate(from: projection) else {
            return nil
        }

        return bearingDegrees(from: coordinate, to: lookaheadCoordinate)
    }

    func closestRouteProjection(to coordinate: CLLocationCoordinate2D) -> RouteProjection? {
        guard routeCoordinates.count > 1 else {
            return nil
        }

        let userPoint = MKMapPoint(coordinate)
        var closestProjection: RouteProjection?

        for index in 0..<(routeCoordinates.count - 1) {
            let startPoint = MKMapPoint(routeCoordinates[index])
            let endPoint = MKMapPoint(routeCoordinates[index + 1])
            let deltaX = endPoint.x - startPoint.x
            let deltaY = endPoint.y - startPoint.y
            let segmentLengthSquared = deltaX * deltaX + deltaY * deltaY
            guard segmentLengthSquared > 0 else {
                continue
            }

            let rawFraction = ((userPoint.x - startPoint.x) * deltaX + (userPoint.y - startPoint.y) * deltaY)
                / segmentLengthSquared
            let fraction = min(1, max(0, rawFraction))
            let projectedPoint = MKMapPoint(
                x: startPoint.x + deltaX * fraction,
                y: startPoint.y + deltaY * fraction
            )
            let distanceMeters = userPoint.distance(to: projectedPoint)

            if closestProjection == nil || distanceMeters < (closestProjection?.distanceMeters ?? .infinity) {
                closestProjection = RouteProjection(
                    segmentIndex: index,
                    point: projectedPoint,
                    distanceMeters: distanceMeters
                )
            }
        }

        return closestProjection
    }

    func lookaheadCoordinate(
        from projection: RouteProjection,
        lookaheadMeters: CLLocationDistance = 12
    ) -> CLLocationCoordinate2D? {
        guard routeCoordinates.indices.contains(projection.segmentIndex + 1) else {
            return routeCoordinates.last
        }

        var remainingLookahead = lookaheadMeters
        var currentPoint = projection.point

        for index in projection.segmentIndex..<(routeCoordinates.count - 1) {
            let endPoint = MKMapPoint(routeCoordinates[index + 1])
            let distanceToEnd = currentPoint.distance(to: endPoint)

            if distanceToEnd >= remainingLookahead, distanceToEnd > 0 {
                let fraction = remainingLookahead / distanceToEnd
                return MKMapPoint(
                    x: currentPoint.x + (endPoint.x - currentPoint.x) * fraction,
                    y: currentPoint.y + (endPoint.y - currentPoint.y) * fraction
                ).coordinate
            }

            remainingLookahead -= distanceToEnd
            currentPoint = endPoint
        }

        return routeCoordinates.last
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            dismiss()
        }
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

private enum RouteError: Error {
    case noRoute
}

private struct RouteProjection {
    let segmentIndex: Int
    let point: MKMapPoint
    let distanceMeters: CLLocationDistance
}

private struct RouteInstruction {
    let text: String
    let endCoordinate: CLLocationCoordinate2D?
}

private struct RouteData {
    let coordinates: [CLLocationCoordinate2D]
    let instructions: [RouteInstruction]

    init(route: MKRoute, destinationName: String) {
        coordinates = route.polyline.routeCoordinates

        let stepInstructions = route.steps.compactMap { step -> RouteInstruction? in
            let trimmedInstruction = step.instructions.trimmingCharacters(in: .whitespacesAndNewlines)
            let coordinates = step.polyline.routeCoordinates
            let endCoordinate = coordinates.last

            guard !trimmedInstruction.isEmpty else {
                return nil
            }

            return RouteInstruction(
                text: trimmedInstruction,
                endCoordinate: endCoordinate
            )
        }

        if stepInstructions.isEmpty {
            instructions = [
                RouteInstruction(
                    text: "Head toward \(destinationName)",
                    endCoordinate: coordinates.last
                )
            ]
        } else {
            instructions = stepInstructions
        }
    }
}

private extension MKPolyline {
    var routeCoordinates: [CLLocationCoordinate2D] {
        var coordinates = Array(
            repeating: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            count: pointCount
        )
        getCoordinates(
            &coordinates,
            range: NSRange(location: 0, length: pointCount)
        )
        return coordinates
    }
}

#Preview {
    FindingExperienceView()
}
