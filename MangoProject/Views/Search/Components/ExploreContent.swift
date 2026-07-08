import SwiftUI
import MapKit

struct ExploreContent: View {
    @Binding var selectedCategory: String
    @ObservedObject var locationManager: AppLocationManager
    @ObservedObject var viewModel: MainMapViewModel

    @State private var mapPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: -6.2994, longitude: 106.6533),
            latitudinalMeters: 800,
            longitudinalMeters: 800
        )
    )
    @State private var selectedPlace: NearbyFoodPlace?
    @State private var didCenterOnUser = false

    private var headingDegrees: CLLocationDirection? {
        guard let heading = locationManager.heading else { return nil }
        return heading.trueHeading >= 0 ? heading.trueHeading : heading.magneticHeading
    }

    private var annotations: [MainMapAnnotation] {
        var result: [MainMapAnnotation] = viewModel.places.map { .place($0) }
        if let loc = locationManager.location {
            result.append(.user(loc.coordinate, headingDegrees))
        }
        return result
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Explore")
                    .font(.system(size: 34, weight: .bold))
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                CategoryChipRow(selected: $selectedCategory)

                mapSection

                nearestSection

                Spacer(minLength: 24)
            }
        }
        .onChange(of: locationManager.location) { _, newLocation in
            guard !didCenterOnUser, let newLocation else { return }
            didCenterOnUser = true
            mapPosition = .region(MKCoordinateRegion(
                center: newLocation.coordinate,
                latitudinalMeters: 800,
                longitudinalMeters: 800
            ))
        }
        .navigationDestination(item: $selectedPlace) { place in
            FindingExperienceView(
                targetName: place.name,
                targetDistanceText: place.distanceText,
                targetCategory: place.category,
                targetLocationName: place.addressLines.first ?? "",
                targetAddressLines: place.addressLines,
                targetCoordinate: place.coordinate,
                locationManager: locationManager
            )
        }
    }

    private var mapSection: some View {
        Map(position: $mapPosition) {
            ForEach(annotations) { annotation in
                Annotation("", coordinate: annotation.coordinate) {
                    switch annotation {
                    case .user(_, let heading):
                        UserHeadingMarker(headingDegrees: heading)
                    case .place(let place):
                        FoodMapPin(isFocused: selectedPlace?.id == place.id)
                            .onTapGesture { selectedPlace = place }
                    }
                }
            }
        }
        .onMapCameraChange(frequency: .onEnd) { context in
            Task {
                await viewModel.refreshPlaces(
                    in: context.region,
                    userLocation: locationManager.location
                )
            }
        }
        .frame(height: 220)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .padding(.horizontal, 16)
        .accessibilityLabel("Interactive map showing nearby food places")
    }

    private var nearestSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Nearest to You")
                .font(.system(size: 22, weight: .bold))
                .padding(.horizontal, 16)

            if viewModel.places.isEmpty {
                Text("Looking for nearby places…")
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 16)
            } else {
                VStack(spacing: 10) {
                    ForEach(filteredPlaces) { place in
                        RestaurantCard(place: place) {
                            selectedPlace = place
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private var filteredPlaces: [NearbyFoodPlace] {
        guard selectedCategory != "All" else { return viewModel.places }
        return viewModel.places.filter {
            $0.category.localizedCaseInsensitiveContains(selectedCategory)
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var category = "All"
        var body: some View {
            NavigationStack {
                ExploreContent(
                    selectedCategory: $category,
                    locationManager: AppLocationManager(),
                    viewModel: MainMapViewModel()
                )
            }
        }
    }
    return PreviewWrapper()
}
