import SwiftUI
import MapKit

struct RestaurantDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: RestaurantDetailViewModel
    @State private var showingDirections = false
    
    init(place: NearbyFoodPlace) {
        _viewModel = StateObject(wrappedValue: RestaurantDetailViewModel(place: place))
    }
    
    private var place: NearbyFoodPlace { viewModel.place }
    
    var body: some View {
        GeometryReader { geo in
            let imageHeight = geo.size.height * 0.35

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // ── Hero Image ──────────────────────────────────
                    Image("arabica_storefront")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: imageHeight)
                        .clipped()

                    // ── Info Section ────────────────────────────────
                    VStack(alignment: .leading, spacing: 10) {

                        // Name
                        Text(place.name)
                            .font(.title.bold())
                            .foregroundStyle(.primary)

                        // Rating
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundStyle(.orange)
                            Text("4.0")
                                .font(.subheadline.bold())
                            Text("/ 5.0")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        // Address
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "location.fill")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.top, 2)
                            Text(viewModel.resolvedAddress.isEmpty
                                 ? (place.address.isEmpty ? "The Breeze, BSD City, Tangerang" : place.address)
                                 : viewModel.resolvedAddress)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }

                        // Hours
                        HStack(spacing: 8) {
                            Image(systemName: "clock")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("07:00 – 23:00")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        // Halal Card
                        HalalCertificateCard(
                            certificateNumber: place.certificateNumber,
                            certificateIssueDate: place.certificateIssueDate
                        )

                        // Action buttons
                        RestaurantActionButtons(
                            onDirectionsTap: { showingDirections = true },
                            onCallTap: {
                                if let phone = viewModel.resolvedPhone ?? place.phoneNumber,
                                   let url = URL(string: "tel://\(phone.replacingOccurrences(of: " ", with: ""))") {
                                    UIApplication.shared.open(url)
                                }
                            },
                            onSaveTap: {
                                // Save action
                            }
                        )

                        // Collect Points
                        CollectPointsButton(
                            onTap: {
                                // Collect points action
                            }
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 14)
                    .padding(.bottom, 10)

                    // ── Photo Strip ─────────────────────────────────
                    RestaurantPhotoScroll()
                }
            }
            .scrollIndicators(.hidden)
            .ignoresSafeArea(.container, edges: [.top, .bottom])
        }
        .overlay(alignment: .top) {
            RestaurantFloatingButtons(
                placeName: place.name,
                placeURL: place.url?.absoluteString ?? "",
                onDismiss: { dismiss() }
            )
        }
        .onAppear { viewModel.loadDetails() }
        .fullScreenCover(isPresented: $showingDirections) {
            DirectionPageView(place: place, locationManager: AppLocationManager())
        }
    }
}

#Preview {
    let coordinate = CLLocationCoordinate2D(latitude: -6.30131539, longitude: 106.6536841)
    let placemark = MKPlacemark(coordinate: coordinate)
    let mapItem = MKMapItem(placemark: placemark)
    mapItem.name = "Arabica The Breeze BSD City"
    
    return NavigationStack {
        RestaurantDetailView(
            place: NearbyFoodPlace(
                id: "Arabica-1",
                name: "Arabica The Breeze BSD City",
                address: "The Breeze, Bsd City, Jl. BSD Green Office Park Jl. BSD Grand Boulevard Unit L19, Sampora, Kec. Cisauk, Kabupaten Tangerang, Banten 15345",
                category: "Cafe",
                coordinate: coordinate,
                phoneNumber: "021-123456",
                url: URL(string: "https://arabicacoffee.jp"),
                distanceInMeters: 120,
                mapItem: mapItem,
                businessName: "PT. DYNAPLAST",
                certificateNumber: "0123456789",
                certificateIssueDate: "15 July 2025",
                totalProducts: 117,
                isHalal: true
            )
        )
    }
}
