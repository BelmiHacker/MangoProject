//
//  DirectionPageView.swift
//  MangoProject
//

import MapKit
import SwiftUI

struct DirectionPageView: View {

    @Environment(\.dismiss) private var dismiss

    let place: NearbyFoodPlace
    let locationManager: AppLocationManager
    var onFinished: (() -> Void)? = nil

    @StateObject private var viewModel: DirectionViewModel
    @State private var isNavigating = false
    @State private var sheetDetent: PresentationDetent = .medium

    private let compactDetent = PresentationDetent.height(100)

    init(
        place: NearbyFoodPlace,
        locationManager: AppLocationManager,
        onFinished: (() -> Void)? = nil
    ) {
        self.place = place
        self.locationManager = locationManager
        self.onFinished = onFinished
        _viewModel = StateObject(wrappedValue: DirectionViewModel(
            destination: place,
            locationManager: locationManager
        ))
    }

    /// Closes the walking-navigation screen, this direction screen, and
    /// forwards up so the presenter can clear its own state (and switch
    /// tabs back to Home, if it's able to).
    private func finishAfterArrival() {
        isNavigating = false
        dismiss()
        onFinished?()
    }

    private var isCompact: Bool { sheetDetent == compactDetent }

    var body: some View {
        ZStack {
            mapLayer
                .ignoresSafeArea()
            backButtonOverlay
        }
        .sheet(isPresented: .constant(true)) {
            sheetContent
                .fullScreenCover(isPresented: $isNavigating) {
                    FindingExperienceView(
                        targetName: place.name,
                        targetDistanceText: place.distanceText,
                        targetCategory: place.category,
                        targetLocationName: "Apple Maps",
                        targetAddressLines: place.addressLines,
                        targetCoordinate: place.coordinate,
                        locationManager: locationManager,
                        onArrivedFinish: finishAfterArrival
                    )
                }
                .interactiveDismissDisabled(true)
                .presentationDetents([compactDetent, .medium, .large], selection: $sheetDetent)
                .presentationDragIndicator(.visible)
                .presentationBackgroundInteraction(.enabled)
                .presentationBackground(.clear)
                .presentationCornerRadius(28)
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .task {
            await viewModel.fetchRoute()
        }
    }

    // MARK: - Map

    private var mapLayer: some View {
        Map(position: $viewModel.cameraPosition) {
            if let route = viewModel.route {
                MapPolyline(route.polyline)
                    .stroke(Color(.systemBlue), lineWidth: 8)
            }

            Annotation("", coordinate: place.coordinate, anchor: .bottom) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.red)
            }

            if let coord = locationManager.location?.coordinate {
                Annotation("", coordinate: coord, anchor: .center) {
                    UserHeadingMarker(headingDegrees: viewModel.headingDegrees)
                        .rotationEffect(.degrees(-viewModel.mapHeading))
                        .allowsHitTesting(false)
                }
            }
        }
        .onMapCameraChange(frequency: .continuous) { viewModel.onCameraChange($0) }
        .mapControls { }
    }

    // MARK: - Back Button

    private var backButtonOverlay: some View {
        VStack {
            HStack {
                Button { dismiss() } label: {
                    ZStack {
                        if #available(iOS 26, *) {
                            Circle().fill(.clear).glassEffect(in: Circle())
                        } else {
                            Circle().fill(.ultraThinMaterial)
                        }
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.primary)
                    }
                    .frame(width: 52, height: 52)
                }
                .buttonStyle(.plain)
                .contentShape(Circle())
                .padding(.leading, 16)
                .padding(.top, 8)
                Spacer()
            }
            Spacer()
        }
    }

    // MARK: - Sheet Content

    private var sheetContent: some View {
        VStack(spacing: 0) {
            if isCompact {
                compactInfoRow
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
            } else {
                fullSheetContent
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .background {
            if #available(iOS 26, *) {
                Color.clear
                    .glassEffect(in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            } else {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(.ultraThinMaterial)
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isCompact)
    }

    // MARK: - Compact Row (shown when sheet is dragged to bottom)

    private var compactInfoRow: some View {
        HStack(spacing: 12) {
            Image(systemName: "figure.walk")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(viewModel.durationText)
                        .font(.headline)
                    Text("·")
                        .foregroundStyle(.secondary)
                    Text("ETA \(viewModel.etaText)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("·")
                        .foregroundStyle(.secondary)
                    Text(viewModel.distanceText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Text(place.name)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
    }

    // MARK: - Full Content (medium / large detent)

    private var fullSheetContent: some View {
        VStack(spacing: 0) {
            VStack(spacing: 14) {
                if viewModel.isLoading {
                    HStack(spacing: 10) {
                        ProgressView()
                        Text("Finding walking route…")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                } else {
                    HStack(spacing: 0) {
                        Image(systemName: "figure.walk")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .padding(.trailing, 6)

                        Text(viewModel.durationText)
                            .font(.title2.bold())

                        Text("  ·  ")
                            .foregroundStyle(.secondary)

                        VStack(alignment: .leading, spacing: 1) {
                            Text("ETA \(viewModel.etaText) · \(viewModel.distanceText)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text(place.name)
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                                .lineLimit(1)
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 4)

                    // No formal route doesn't block navigation — we still
                    // know the straight-line distance/time above, and
                    // FindingExperienceView guides by direct GPS bearing
                    // when there's no route polyline to follow.
                    if viewModel.errorMessage != nil {
                        Text("No walking route found — you'll be guided straight to the location instead.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 4)
                    }
                }

                Button {
                    isNavigating = true
                } label: {
                    Text("Go")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(viewModel.isLoading ? Color(.systemGray3) : Color.green)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)
                .disabled(viewModel.isLoading)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)

            if !viewModel.steps.isEmpty {
                Divider()

                ScrollView {
                    DirectionStepsList(steps: viewModel.steps)
                        .padding(.bottom, 48)
                }
            }
        }
    }
}
