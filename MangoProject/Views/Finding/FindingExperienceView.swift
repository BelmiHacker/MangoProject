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
import UIKit

struct FindingExperienceView: View {
    @Environment(\.dismiss) private var dismiss

    let targetName: String
    let targetDistanceText: String
    let targetCategory: String
    let targetLocationName: String
    let targetAddressLines: [String]
    let targetCoordinate: CLLocationCoordinate2D?
    var onArrivedFinish: () -> Void = {}

    private let compactDetent = PresentationDetent.height(104)
    private let mediumDetent = PresentationDetent.fraction(0.52)
    private let arrivalThresholdMeters: CLLocationDistance = 2

    /// Within this range, per-step route breakdown (bearing, instruction
    /// text, and the step carousel) is ignored in favor of a single reading
    /// straight to the destination — MapKit's route steps can otherwise show
    /// a short segment's own length (e.g. "2 m" for the current road) that
    /// has nothing to do with the true remaining distance to the target.
    private let closeRangeMeters: CLLocationDistance = 10

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
    @State private var hasArrived = false
    @State private var isShowingArrivedView = false
    @State private var lastProximityHapticDate: Date?

    // Must be @State, not a plain `let` — this View re-initializes its
    // struct on every GPS update (it observes `locationManager.location`),
    // and a `let` Combine publisher would be rebuilt from scratch each time,
    // constantly tearing down and resubscribing `.onReceive` below before
    // the timer ever got a chance to fire. That silently starved
    // `updateDisplayedDistance()` — the one place the arrival check lives —
    // of ticks, which is why arrival could fail to trigger even once the
    // screen displayed "0 m".
    @State private var distanceSmoothingTimer = Timer.publish(every: 0.08, on: .main, in: .common).autoconnect()
    private let proximityHapticStartMeters: CLLocationDistance = 10

    init(
        targetName: String = "Tamper Coffee",
        targetDistanceText: String = "150 m",
        targetCategory: String = "Coffee Shop",
        targetLocationName: String = "The Breeze",
        targetAddressLines: [String] = ["Sampora", "Tangerang", "Banten", "Indonesia"],
        targetCoordinate: CLLocationCoordinate2D? = nil,
        locationManager: AppLocationManager = AppLocationManager(),
        onArrivedFinish: @escaping () -> Void = {}
    ) {
        self.targetName = targetName
        self.targetDistanceText = targetDistanceText
        self.targetCategory = targetCategory
        self.targetLocationName = targetLocationName
        self.targetAddressLines = targetAddressLines
        self.targetCoordinate = targetCoordinate
        self.locationManager = locationManager
        self.onArrivedFinish = onArrivedFinish
    }

    /// True once the live GPS distance to the target is within
    /// `closeRangeMeters` — the point where per-step route breakdown stops
    /// being trustworthy/useful and a single direct reading takes over.
    private var isCloseToDestination: Bool {
        guard let liveDistanceMeters else {
            return false
        }
        return liveDistanceMeters <= closeRangeMeters
    }

    private var findingState: FindingNavigationState {
        let usesSingleStepFallback = navigationSteps.isEmpty || isCloseToDestination
        let steps = usesSingleStepFallback
            ? [NavigationStep(id: 0, instruction: instructionText, distanceText: displayedDistanceText, symbolName: "arrow.up")]
            : navigationSteps
        // The fallback array only ever has one entry (id 0) — reporting the
        // real route's step index here would ask the carousel to select a
        // page that doesn't exist in `steps`.
        let stepProgress = usesSingleStepFallback ? 0 : stepProgressIndex
        return FindingNavigationState(
            targetName: targetName,
            distanceText: displayedDistanceText,
            directionPrefixText: "to your",
            directionFocusText: directionFocusText,
            arrowAngle: arrowDisplayAngle,
            instructionDistanceText: displayedDistanceText,
            instructionText: instructionText,
            stepProgress: stepProgress,
            stepCount: steps.count,
            proximityProgress: displayedProximityProgress,
            steps: steps
        )
    }

    private var placeDetailState: FindingPlaceDetailState {
        FindingPlaceDetailState(
            name: targetName,
            category: targetCategory,
            locationName: targetLocationName,
            websiteText: "",
            hoursStatus: "Open",
            hoursText: "07.00 - 22.00",
            distanceText: displayedDistanceText,
            addressLines: targetAddressLines,
            routeSteps: navigationSteps
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
            .fullScreenCover(isPresented: $isShowingArrivedView) {
                ArrivedView(targetName: targetName, onBackToHome: onArrivedFinish)
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

        return "\(Int(distance.rounded())) meter"
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

        if let currentDistance = displayedDistanceMeters {
            let delta = targetDistance - currentDistance
            displayedDistanceMeters = abs(delta) > 1 ? currentDistance + (delta > 0 ? 1 : -1) : targetDistance
        } else {
            displayedDistanceMeters = targetDistance
        }

        // Check arrival against whichever of the raw GPS reading or the
        // (slightly lagging) smoothed on-screen value is smaller, so arrival
        // always fires by the time the screen shows a number at or under the
        // threshold — never a case where the display reads "0 m" but nothing
        // happens because the two values momentarily disagreed.
        let effectiveDistance = min(targetDistance, displayedDistanceMeters ?? targetDistance)

        if !hasArrived, effectiveDistance <= arrivalThresholdMeters {
            hasArrived = true
            triggerArrivalHaptics()

            // A View can't present a sheet and a fullScreenCover at the same
            // time — `isPlaceSheetPresented` is already up for the entire
            // navigation experience, so ArrivedView's presentation request
            // would otherwise get silently dropped. Dismiss the sheet first,
            // then bring in ArrivedView once that's had time to animate out.
            isPlaceSheetPresented = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                isShowingArrivedView = true
            }
        } else {
            updateProximityHaptics(distance: effectiveDistance)
        }
    }

    /// A few spaced-out success taps rather than one, so arrival reads as a
    /// distinct, unmistakable moment rather than blending into the regular
    /// GPS-update haptics an OS might otherwise coalesce a single tap into.
    func triggerArrivalHaptics() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()

        for tapIndex in 0..<4 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(tapIndex) * 0.35) {
                generator.notificationOccurred(.success)
            }
        }
    }

    /// "Getting warmer" haptics, like Find My's precision finding: starting
    /// at `proximityHapticStartMeters`, pulses fire more often and more
    /// strongly the closer the live GPS distance gets, until arrival hands
    /// off to `triggerArrivalHaptics()`.
    func updateProximityHaptics(distance: CLLocationDistance) {
        guard distance <= proximityHapticStartMeters else {
            return
        }

        let requiredInterval = proximityHapticInterval(forDistance: distance)
        if let lastProximityHapticDate, Date().timeIntervalSince(lastProximityHapticDate) < requiredInterval {
            return
        }

        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.prepare()
        generator.impactOccurred(intensity: proximityHapticIntensity(forDistance: distance))
        lastProximityHapticDate = Date()
    }

    /// `arrivalThresholdMeters` → fires every ~0.12s (fastest),
    /// `proximityHapticStartMeters` → ~0.9s (slowest).
    func proximityHapticInterval(forDistance distance: CLLocationDistance) -> TimeInterval {
        let progress = proximityProgress(forDistance: distance)
        let fastestInterval = 0.12
        let slowestInterval = 0.9
        return slowestInterval - progress * (slowestInterval - fastestInterval)
    }

    /// `arrivalThresholdMeters` → full intensity (1.0), `proximityHapticStartMeters` → faintest (0.4).
    func proximityHapticIntensity(forDistance distance: CLLocationDistance) -> CGFloat {
        let progress = proximityProgress(forDistance: distance)
        let weakestIntensity: CGFloat = 0.4
        let strongestIntensity: CGFloat = 1.0
        return weakestIntensity + CGFloat(progress) * (strongestIntensity - weakestIntensity)
    }

    /// 0 at `proximityHapticStartMeters`, 1 at `arrivalThresholdMeters` (or
    /// closer) — full intensity/frequency is reached right at the arrival
    /// boundary, so the last pulse before "You Have Arrived" takes over
    /// already feels like a peak, not something still ramping up.
    func proximityProgress(forDistance distance: CLLocationDistance) -> Double {
        let clamped = min(max(distance, arrivalThresholdMeters), proximityHapticStartMeters)
        return 1 - (clamped - arrivalThresholdMeters) / (proximityHapticStartMeters - arrivalThresholdMeters)
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

        guard let targetCoordinate else {
            return nil
        }

        // Once close to the destination, point straight at it instead of
        // still following the calculated route's bearing. MapKit's route
        // can otherwise send you toward the nearest known path first (e.g.
        // "Proceed to the route") even when the destination is right there
        // — confusing and pointless this close in.
        if isCloseToDestination {
            return bearingDegrees(from: userCoordinate, to: targetCoordinate)
        }

        if routeCoordinates.count > 1,
           let routeBearing = routeBearing(from: userCoordinate) {
            return routeBearing
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
        currentRouteInstructionIndex ?? 0
    }

    var navigationSteps: [NavigationStep] {
        routeInstructions.enumerated().map { index, instruction in
            let distanceText: String
            if instruction.distanceMeters >= 1000 {
                distanceText = String(format: "%.1f km", instruction.distanceMeters / 1000)
            } else if instruction.distanceMeters > 0 {
                distanceText = "\(Int(instruction.distanceMeters.rounded())) meter"
            } else {
                distanceText = displayedDistanceText
            }
            return NavigationStep(
                id: index,
                instruction: instruction.text,
                distanceText: distanceText,
                symbolName: NavigationStep.symbol(for: instruction.text)
            )
        }
    }

    var instructionText: String {
        guard targetCoordinate != nil else {
            return "Finding target"
        }

        // Mirrors destinationBearing: this close in, ignore route-correction
        // instructions like "Proceed to the route" and just say to head
        // toward the target, matching the arrow.
        if isCloseToDestination {
            return "Head toward \(targetName)"
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
        if #available(iOS 26, *) {
            request.source = MKMapItem(
                location: CLLocation(latitude: origin.latitude, longitude: origin.longitude),
                address: nil
            )
            request.destination = MKMapItem(
                location: CLLocation(latitude: destinationCoordinate.latitude, longitude: destinationCoordinate.longitude),
                address: nil
            )
        } else {
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: origin))
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoordinate))
        }
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
    let distanceMeters: CLLocationDistance
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
                endCoordinate: endCoordinate,
                distanceMeters: step.distance
            )
        }

        if stepInstructions.isEmpty {
            instructions = [
                RouteInstruction(
                    text: "Head toward \(destinationName)",
                    endCoordinate: coordinates.last,
                    distanceMeters: 0
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
