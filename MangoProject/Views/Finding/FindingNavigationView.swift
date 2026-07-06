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

                Spacer(minLength: 48)

                directionDial

                Spacer(minLength: 180)
            }
            .padding(.horizontal, 18)
            .padding(.top, 50)
        }
    }
}

private extension FindingNavigationView {
    var background: some View {
        Color(red: 0.96, green: 0.95, blue: 0.92)
        .ignoresSafeArea()
    }

    var instructionCard: some View {
        HStack(spacing: 18) {
            Image(systemName: "location.north.fill")
                .font(.system(size: 58, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 92)

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
        .background(Color(red: 0.10, green: 0.10, blue: 0.10))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    var directionDial: some View {
        DirectionDialView(angle: state.arrowAngle)
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
}

private struct DirectionDialView: View {
    let angle: Double

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.87, green: 0.87, blue: 0.87))

            Circle()
                .stroke(Color(red: 0.37, green: 0.37, blue: 0.37), lineWidth: 34)

            Circle()
                .stroke(Color(red: 0.70, green: 0.70, blue: 0.70), lineWidth: 26)
                .padding(42)

            Image(systemName: "arrow.right")
                .font(.system(size: 160, weight: .heavy))
                .foregroundStyle(Color(red: 0.08, green: 0.08, blue: 0.08))
                .rotationEffect(.degrees(angle))
        }
        .frame(width: 300, height: 300)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: angle)
    }
}

private struct CircleControlButton: View {
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 88, height: 88)
                .background(Color.white.opacity(0.18))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
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
            stepCount: 6
        )
    )
}
