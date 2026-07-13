//
//  PlaceDetailSheetView.swift
//  MangoProject
//

import SwiftUI

struct PlaceDetailSheetView: View {
    let state: FindingPlaceDetailState
    var onClose: () -> Void = {}

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                dragHandle
                header
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)

                Divider().overlay(Color.white.opacity(0.12))

                infoSection
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)

                if !state.routeSteps.isEmpty {
                    Divider().overlay(Color.white.opacity(0.12))

                    routeOverview
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 34)
                }
            }
        }
        .scrollIndicators(.hidden)
        .background(sheetBackground)
    }
}

private extension PlaceDetailSheetView {
    var sheetBackground: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(Color(red: 0.10, green: 0.10, blue: 0.11).opacity(0.96))
    }

    var dragHandle: some View {
        Capsule()
            .fill(Color.white.opacity(0.28))
            .frame(width: 40, height: 5)
            .padding(.top, 10)
            .padding(.bottom, 16)
    }

    var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(state.name)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                Text(state.category)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(.white.opacity(0.55))
            }

            Spacer()

            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white.opacity(0.7))
                    .frame(width: 30, height: 30)
                    .background(Color.white.opacity(0.12))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
    }

    var infoSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            InfoRow(
                icon: "clock.fill",
                label: state.hoursStatus,
                labelColor: .green,
                detail: state.hoursText
            )
            InfoRow(
                icon: "point.topleft.down.curvedto.point.bottomright.up",
                label: "Distance",
                labelColor: .white,
                detail: state.distanceText
            )
            if !state.addressLines.isEmpty {
                InfoRow(
                    icon: "mappin.circle.fill",
                    label: "Address",
                    labelColor: .white,
                    detail: state.addressLines.joined(separator: ", ")
                )
            }
        }
    }

    var routeOverview: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Route Overview")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
                .padding(.bottom, 14)

            ForEach(state.routeSteps) { step in
                HStack(alignment: .top, spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.10))
                            .frame(width: 34, height: 34)
                        Image(systemName: step.symbolName)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.white)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(step.instruction)
                            .font(.system(size: 15))
                            .foregroundStyle(.white)
                            .fixedSize(horizontal: false, vertical: true)
                        if !step.distanceText.isEmpty {
                            Text(step.distanceText)
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.48))
                        }
                    }

                    Spacer(minLength: 0)
                }
                .padding(.vertical, 8)

                if step.id != state.routeSteps.last?.id {
                    Divider()
                        .overlay(Color.white.opacity(0.08))
                        .padding(.leading, 48)
                }
            }
        }
    }
}

// MARK: - Info Row

private struct InfoRow: View {
    let icon: String
    let label: String
    let labelColor: Color
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white.opacity(0.5))
                .frame(width: 22)

            Text(label)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(labelColor)

            Spacer()

            Text(detail)
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(.white.opacity(0.75))
                .multilineTextAlignment(.trailing)
        }
    }
}

// MARK: - Compact Sheet

struct CompactPlaceSheetView: View {
    let state: FindingPlaceDetailState
    var onClose: () -> Void = {}

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.primary.opacity(0.25))
                .frame(width: 36, height: 5)
                .padding(.top, 10)
                .padding(.bottom, 8)

            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("To \(state.name)")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Text(state.distanceText)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                .padding(.leading, 22)

                Spacer()

                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.secondary)
                        .frame(width: 28, height: 28)
                        .background(Color.primary.opacity(0.1))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .padding(.trailing, 16)
                .accessibilityLabel("Exit navigation")
            }
            .padding(.bottom, 14)
        }
        .frame(maxWidth: .infinity)
        .background {
            if #available(iOS 26, *) {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(.clear)
                    .glassEffect(in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            } else {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(.ultraThinMaterial)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .padding(.horizontal, 12)
        .padding(.bottom, 8)
    }
}

#Preview {
    PlaceDetailSheetView(
        state: FindingPlaceDetailState(
            name: "Tamper Coffee",
            category: "Coffee Shop",
            locationName: "The Breeze",
            websiteText: "",
            hoursStatus: "Open",
            hoursText: "07.00 - 22.00",
            distanceText: "150 m",
            addressLines: ["Sampora", "Tangerang", "Banten"],
            routeSteps: [
                NavigationStep(id: 0, instruction: "Head south on Jalan BSD Raya Utama", distanceText: "85 m", symbolName: "arrow.up"),
                NavigationStep(id: 1, instruction: "Turn left on Jalan Pahlawan Seribu", distanceText: "200 m", symbolName: "arrow.turn.up.left"),
                NavigationStep(id: 2, instruction: "Arrive at Tamper Coffee", distanceText: "10 m", symbolName: "mappin.circle.fill")
            ]
        )
    )
}
