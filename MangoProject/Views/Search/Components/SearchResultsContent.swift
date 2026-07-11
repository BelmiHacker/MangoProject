import SwiftUI

struct SearchResultsContent: View {
    let query: String
    @Binding var selectedCategory: String
    @ObservedObject var viewModel: MainMapViewModel
    @ObservedObject var locationManager: AppLocationManager

    @State private var selectedPlace: NearbyFoodPlace?

    private var filteredPlaces: [NearbyFoodPlace] {
        let categoryFiltered: [NearbyFoodPlace]
        if selectedCategory == "All" {
            categoryFiltered = viewModel.places
        } else {
            categoryFiltered = viewModel.places.filter {
                $0.category.localizedCaseInsensitiveContains(selectedCategory)
            }
        }
        guard !query.isEmpty else { return categoryFiltered }
        return categoryFiltered.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                CategoryChipRow(selected: $selectedCategory)
                    .padding(.top, 12)

                if filteredPlaces.isEmpty {
                    Text(viewModel.places.isEmpty ? "Looking for places…" : "No results found")
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                        .padding(.top, 32)
                } else {
                    VStack(spacing: 10) {
                        ForEach(filteredPlaces) { place in
                            RestaurantCard(place: place) {
                                selectedPlace = place
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }

                Spacer(minLength: 24)
            }
        }
        .navigationDestination(item: $selectedPlace) { place in
            DirectionPageView(
                place: place,
                locationManager: locationManager
            )
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var category = "All"
        var body: some View {
            NavigationStack {
                SearchResultsContent(
                    query: "Coffee",
                    selectedCategory: $category,
                    viewModel: MainMapViewModel(),
                    locationManager: AppLocationManager()
                )
            }
        }
    }
    return PreviewWrapper()
}
