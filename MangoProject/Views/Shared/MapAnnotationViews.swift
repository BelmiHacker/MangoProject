//
//  MapAnnotationViews.swift
//  MangoProject
//

import CoreLocation
import SwiftUI

// MARK: - Annotation Model

enum MainMapAnnotation: Identifiable {
    case user(CLLocationCoordinate2D, CLLocationDirection?)
    case place(NearbyFoodPlace)

    var id: String {
        switch self {
        case .user: return "user-location-heading"
        case .place(let place): return place.id
        }
    }

    var coordinate: CLLocationCoordinate2D {
        switch self {
        case .user(let coordinate, _): return coordinate
        case .place(let place): return place.coordinate
        }
    }
}

// MARK: - User Heading Marker

struct UserHeadingMarker: View {
    let headingDegrees: CLLocationDirection?
    @State private var displayedHeading: CLLocationDirection = 0
    @State private var hasDisplayedHeading = false

    var body: some View {
        ZStack {
            if headingDegrees != nil {
                ZStack {
                    HeadingConeShape(spread: 64)
                        .fill(Color(.systemBlue).opacity(0.10))

                    HeadingConeShape(spread: 42)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(.systemBlue).opacity(0.30),
                                    Color(.systemBlue).opacity(0.12)
                                ],
                                startPoint: .center,
                                endPoint: .top
                            )
                        )
                }
                .frame(width: 78, height: 78)
                .rotationEffect(.degrees(displayedHeading))
                .animation(.easeInOut(duration: 0.22), value: displayedHeading)
            }

            Circle()
                .fill(.white)
                .frame(width: 28, height: 28)
                .shadow(color: .black.opacity(0.18), radius: 5, y: 2)

            Circle()
                .fill(Color(.systemBlue))
                .frame(width: 20, height: 20)
        }
        .frame(width: 78, height: 78)
        .onAppear {
            updateDisplayedHeading(animatedHeading: headingDegrees)
        }
        .onChange(of: headingDegrees) { _, newHeading in
            updateDisplayedHeading(animatedHeading: newHeading)
        }
    }

    private func updateDisplayedHeading(animatedHeading newHeading: CLLocationDirection?) {
        guard let newHeading else { return }

        if !hasDisplayedHeading {
            displayedHeading = newHeading
            hasDisplayedHeading = true
            return
        }

        let currentWrapped = displayedHeading.truncatingRemainder(dividingBy: 360)
        let normalizedCurrent = currentWrapped < 0 ? currentWrapped + 360 : currentWrapped
        let shortestDelta = ((newHeading - normalizedCurrent + 540).truncatingRemainder(dividingBy: 360)) - 180
        displayedHeading += shortestDelta
    }
}

// MARK: - Heading Cone Shape

struct HeadingConeShape: Shape {
    let spread: Double

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) * 0.48
        let startAngle = Angle.degrees(-90 - spread / 2)
        let endAngle = Angle.degrees(-90 + spread / 2)

        var path = Path()
        path.move(to: center)
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        path.closeSubpath()
        return path
    }
}

// MARK: - Food Map Pin

struct FoodMapPin: View {
    let isFocused: Bool

    var body: some View {
        Image(systemName: "fork.knife.circle.fill")
            .font(.system(size: isFocused ? 40 : 32))
            .foregroundStyle(isFocused ? Color(.systemOrange) : Color(.systemGreen))
            .background(
                Circle()
                    .fill(Color(.systemBackground))
                    .frame(width: isFocused ? 34 : 28, height: isFocused ? 34 : 28)
            )
            .shadow(color: .black.opacity(isFocused ? 0.28 : 0.16), radius: isFocused ? 10 : 5, y: 4)
            .scaleEffect(isFocused ? 1.08 : 1)
            .animation(.snappy, value: isFocused)
    }
}
