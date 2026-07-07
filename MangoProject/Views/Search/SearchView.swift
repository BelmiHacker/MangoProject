import SwiftUI

struct SearchView: View {
    @Binding var searchText: String
    let isSearchFocused: Bool

    @StateObject private var locationManager = AppLocationManager()
    @StateObject private var viewModel = MainMapViewModel()
    @State private var selectedCategory: String = "All"

    private var searchState: SearchState {
        if !searchText.isEmpty { return .results }
        if isSearchFocused { return .active }
        return .explore
    }

    var body: some View {
        NavigationStack {
            contentView
                .background(Color(.systemBackground).ignoresSafeArea())
                .onAppear { locationManager.requestAccessAndStart() }
        }
        .animation(.spring(response: 0.3), value: searchState)
    }

    @ViewBuilder
    private var contentView: some View {
        switch searchState {
        case .explore:
            ExploreContent(
                selectedCategory: $selectedCategory,
                locationManager: locationManager,
                viewModel: viewModel
            )
        case .active:
            SearchActiveContent()
        case .results:
            SearchResultsContent(
                query: searchText,
                selectedCategory: $selectedCategory,
                viewModel: viewModel,
                locationManager: locationManager
            )
        }
    }
}

private enum SearchState: Equatable {
    case explore, active, results
}

#Preview {
    SearchView(searchText: .constant(""), isSearchFocused: false)
}
