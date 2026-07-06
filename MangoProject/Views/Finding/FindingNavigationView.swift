//
//  FindingNavigationView.swift
//  MangoProject
//
//  Created by Belmiro Kayru on 04/07/26.
//

import SwiftUI

struct FindingNavigationView: View {
    let state: FindingNavigationState
    var onClose: () -> Void = {}
    var onPlaySound: () -> Void = {}

    var body: some View {
        ZStack {
            background

            VStack(spacing: 0) {
                instructionCard

                Spacer(minLength: 20)

                distanceMeter

                Spacer(minLength: 20)

                directionDial

                Spacer(minLength: 120)
            }
            .padding(.horizontal, 18)
            .padding(.top, 12)
        }
    }
}

private extension FindingNavigationView {
    var background: some View {
        LinearGradient(
            colors: [
                Color(red: 0.17, green: 0.18, blue: 0.16),
                Color(red: 0.14, green: 0.13, blue: 0.09)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    var instructionCard: some View {
        HStack(spacing: 18) {
            Image(systemName: "location.north.fill")
                .font(.system(size: 62, weight: .black))
                .foregroundStyle(.white)
                .frame(width: 92)
                .rotationEffect(.degrees(state.arrowAngle + 90))
                .animation(.spring(response: 0.45, dampingFraction: 0.82), value: state.arrowAngle)

            VStack(alignment: .leading, spacing: 4) {
                Text(state.instructionDistanceText)
                    .font(.system(size: 38, weight: .bold))
                    .foregroundStyle(.white)

                Text(state.instructionText)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.white.opacity(0.78))

                progressDots
                    .padding(.top, 4)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 18)
        .frame(maxWidth: .infinity)
        .frame(height: 150)
        .background(Color.black.opacity(0.82))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    var directionDial: some View {
        FindMyDirectionArrowView(
            angle: state.arrowAngle,
            proximityProgress: state.proximityProgress
        )
            .frame(maxWidth: .infinity)
            .accessibilityLabel("Direction arrow")
    }

    var progressDots: some View {
        HStack {
            ForEach(0..<state.stepCount, id: \.self) { index in
                Circle()
                    .fill(index == state.stepProgress ? Color.white : Color.white.opacity(0.5))
                    .frame(width: 10, height: 10)
            }
        }
    }

    var distanceMeter: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Distance remaining")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white.opacity(0.5))

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.white.opacity(0.12))
                    .frame(height: 8)

                GeometryReader { geometry in
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.white.opacity(0.8))
                        .frame(width: geometry.size.width * state.meterProgress, height: 8)
                }
                .frame(height: 8)
            }
            .animation(.easeInOut(duration: 0.08), value: state.meterProgress)
        }
        .padding(.horizontal, 4)
    }

    var isAhead: Bool {
        state.directionFocusText == "ahead"
    }
}

private struct FindMyDirectionArrowView: View {
    let angle: Double
    let proximityProgress: Double

    var body: some View {
        ZStack {
            ProximityGlowView(progress: proximityProgress)
                .opacity(proximityProgress > 0 ? 1 : 0)

            arrow
        }
        .frame(height: 360)
        .animation(.spring(response: 0.5, dampingFraction: 0.82), value: angle)
        .animation(.easeInOut(duration: 0.3), value: proximityProgress)
    }

    var arrow: some View {
        Image(systemName: "arrow.up")
            .font(.system(size: 185, weight: .black))
            .foregroundStyle(.white)
            .rotationEffect(.degrees(angle + 90))
            .shadow(color: .black.opacity(0.12), radius: 8, y: 4)
    }
}

private struct ProximityGlowView: View {
    let progress: Double

    private var normalizedProgress: Double {
        min(max(progress, 0), 1)
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.green.opacity(0.12 + normalizedProgress * 0.18))
                .frame(width: 180 + normalizedProgress * 150, height: 180 + normalizedProgress * 150)
                .blur(radius: 22)

            Circle()
                .fill(Color.green.opacity(0.12 + normalizedProgress * 0.26))
                .frame(width: 92 + normalizedProgress * 92, height: 92 + normalizedProgress * 92)
                .blur(radius: 8)

            Circle()
                .stroke(Color.green.opacity(0.22 + normalizedProgress * 0.38), lineWidth: 2)
                .frame(width: 120 + normalizedProgress * 110, height: 120 + normalizedProgress * 110)
        }
    }
}

#Preview {
    FindingNavigationView(
        state: FindingNavigationState(
            targetName: "Tamper Coffee",
            distanceText: "150 m",
            directionPrefixText: "to your",
            directionFocusText: "right",
            arrowAngle: -45,
            instructionDistanceText: "20 m",
            instructionText: "Take the stairs",
            stepProgress: 0,
            stepCount: 6,
            proximityProgress: 0.5,
            meterProgress: 0.6
        )
    )
}
