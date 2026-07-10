//
//  FindingNavigationView.swift
//  MangoProject
//

import SwiftUI

struct FindingNavigationView: View {
    let state: FindingNavigationState
    var onClose: () -> Void = {}
    var onPlaySound: () -> Void = {}

    @State private var selectedPage: Int = 0

    var body: some View {
        ZStack {
            background

            VStack(spacing: 0) {
                instructionCarousel

                Spacer(minLength: 24)

                directionDial

                Spacer(minLength: 120)
            }
            .padding(.horizontal, 18)
            .padding(.top, 12)
        }
        .onAppear {
            selectedPage = state.stepProgress
        }
        .onChange(of: state.stepProgress) { _, newStep in
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                selectedPage = newStep
            }
        }
    }
}

private extension FindingNavigationView {
    var background: some View {
        Color("AppBackground")
            .ignoresSafeArea()
    }

    var instructionCarousel: some View {
        VStack(spacing: 0) {
            TabView(selection: $selectedPage) {
                ForEach(state.steps) { step in
                    stepPage(for: step)
                        .tag(step.id)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 114)

            HStack(spacing: 6) {
                ForEach(state.steps) { step in
                    Circle()
                        .fill(step.id == selectedPage ? Color.white : Color.white.opacity(0.35))
                        .frame(width: 7, height: 7)
                        .animation(.easeInOut(duration: 0.2), value: selectedPage)
                }
            }
            .padding(.vertical, 10)
        }
        .background(Color("Accent"))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    @ViewBuilder
    func stepPage(for step: NavigationStep) -> some View {
        HStack(spacing: 18) {
            Image(systemName: step.symbolName)
                .font(.system(size: 56, weight: .black))
                .foregroundStyle(.white)
                .frame(width: 80)

            VStack(alignment: .leading, spacing: 4) {
                Text(step.distanceText)
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(.white)
                Text(step.instruction)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white.opacity(0.78))
                    .lineLimit(2)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
    }

    var directionDial: some View {
        FindMyDirectionArrowView(
            angle: state.arrowAngle,
            proximityProgress: state.proximityProgress
        )
        .frame(maxWidth: .infinity)
        .accessibilityLabel("Direction arrow")
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
            .foregroundStyle(Color("Accent"))
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
            instructionText: "Head south on Jalan BSD Raya Utama",
            stepProgress: 0,
            stepCount: 3,
            proximityProgress: 0.5,
            steps: [
                NavigationStep(id: 0, instruction: "Head south on Jalan BSD Raya Utama", distanceText: "85 m", symbolName: "arrow.up"),
                NavigationStep(id: 1, instruction: "Turn left on Jalan Pahlawan Seribu", distanceText: "200 m", symbolName: "arrow.turn.up.left"),
                NavigationStep(id: 2, instruction: "Arrive at Tamper Coffee", distanceText: "10 m", symbolName: "mappin.circle.fill")
            ]
        )
    )
}
