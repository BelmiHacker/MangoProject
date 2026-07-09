import SwiftUI
import MapKit

struct RestaurantDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: RestaurantDetailViewModel
    
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
                        halalCertificateCard

                        // Action buttons
                        actionButtonsRow

                        // Collect Points
                        collectPointsButton
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 14)
                    .padding(.bottom, 10)

                    // ── Photo Strip ─────────────────────────────────
                    horizontalPhotoScroll
                }
            }
            .scrollIndicators(.hidden)
            .ignoresSafeArea(.container, edges: [.top, .bottom])
        }
        .overlay(alignment: .top) {
            floatingButtons
        }
        .onAppear { viewModel.loadDetails() }
    }
}

private extension RestaurantDetailView {
    // MARK: - Views
    
    private var floatingButtons: some View {
        HStack {
            Button(action: { dismiss() }) {
                ZStack {
                    if #available(iOS 26, *) {
                        Circle()
                            .fill(.clear)
                            .glassEffect(in: Circle())
                    } else {
                        Circle()
                            .fill(.ultraThinMaterial)
                    }
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.primary)
                }
                .frame(width: 52, height: 52)
            }
            .buttonStyle(.plain)
            .contentShape(Circle())
            
            Spacer()
            
            ShareLink(item: "Check out \(place.name) on Mango! \(place.url?.absoluteString ?? "")") {
                ZStack {
                    if #available(iOS 26, *) {
                        Circle()
                            .fill(.clear)
                            .glassEffect(in: Circle())
                    } else {
                        Circle()
                            .fill(.ultraThinMaterial)
                    }
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.primary)
                }
                .frame(width: 52, height: 52)
            }
            .buttonStyle(.plain)
            .contentShape(Circle())
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    var halalCertificateCard: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                    Text("Certified Halal")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                }
                Text("Verified by MUI")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.85))
                    .padding(.bottom, 4)
                Text("ID: \(place.certificateNumber ?? "0123456789")")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.white.opacity(0.8))
                Text("Valid: \(place.certificateIssueDate ?? "15 July 2025")")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.white.opacity(0.8))
            }
            Spacer()
            HalalIndonesiaLogo()
        }
        .padding(12)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.08, green: 0.12, blue: 0.36),
                    Color(red: 0.28, green: 0.06, blue: 0.50)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
    
    var actionButtonsRow: some View {
        HStack(spacing: 10) {
            // Directions
            Button(action: {
                place.mapItem.openInMaps(launchOptions: [
                    MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking
                ])
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "safari")
                        .font(.system(size: 15, weight: .bold))
                    Text("Directions")
                        .font(.system(size: 15, weight: .bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(Color(red: 0.05, green: 0.35, blue: 0.33))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
            
            // Call
            Button(action: {
                if let phone = viewModel.resolvedPhone ?? place.phoneNumber,
                   let url = URL(string: "tel://\(phone.replacingOccurrences(of: " ", with: ""))") {
                    UIApplication.shared.open(url)
                }
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "phone.fill")
                        .font(.system(size: 13))
                    Text("Call")
                        .font(.system(size: 15, weight: .bold))
                }
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
            
            // Save
            Button(action: {
                // Save action
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "bookmark")
                        .font(.system(size: 13))
                    Text("Save")
                        .font(.system(size: 15, weight: .bold))
                }
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
        }
    }
    
    var collectPointsButton: some View {
        Button(action: {
            // Collect points action
        }) {
            Text("Collect Points")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(Color(red: 0.95, green: 0.60, blue: 0.05))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }
    
    var horizontalPhotoScroll: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(0..<4) { _ in
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(.systemGray5))
                        .frame(width: 100, height: 110)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }
    

}

// MARK: - Halal Indonesia Logo Shape Drawing
struct HalalIndonesiaLogo: View {
    var body: some View {
        VStack(spacing: 2) {
            Canvas { context, size in
                let w = size.width
                let h = size.height
                
                // Draw outline dome / flame
                var path = Path()
                path.move(to: CGPoint(x: w * 0.5, y: 0))
                path.addCurve(
                    to: CGPoint(x: w, y: h * 0.7),
                    control1: CGPoint(x: w * 0.9, y: h * 0.25),
                    control2: CGPoint(x: w, y: h * 0.45)
                )
                path.addLine(to: CGPoint(x: w * 0.82, y: h))
                path.addLine(to: CGPoint(x: w * 0.18, y: h))
                path.addLine(to: CGPoint(x: 0, y: h * 0.7))
                path.addCurve(
                    to: CGPoint(x: w * 0.5, y: 0),
                    control1: CGPoint(x: 0, y: h * 0.45),
                    control2: CGPoint(x: w * 0.1, y: h * 0.25)
                )
                
                context.stroke(path, with: .color(.white), lineWidth: 1.8)
                
                // Internal lines (Arabic script style symbol)
                var linesPath = Path()
                
                // Left curve
                linesPath.move(to: CGPoint(x: w * 0.32, y: h * 0.28))
                linesPath.addQuadCurve(to: CGPoint(x: w * 0.32, y: h * 0.85), control: CGPoint(x: w * 0.26, y: h * 0.55))
                
                // Middle vertical line
                linesPath.move(to: CGPoint(x: w * 0.5, y: h * 0.16))
                linesPath.addLine(to: CGPoint(x: w * 0.5, y: h * 0.85))
                
                // Right curve
                linesPath.move(to: CGPoint(x: w * 0.68, y: h * 0.28))
                linesPath.addQuadCurve(to: CGPoint(x: w * 0.68, y: h * 0.85), control: CGPoint(x: w * 0.74, y: h * 0.55))
                
                // Horizontal connecting line
                linesPath.move(to: CGPoint(x: w * 0.25, y: h * 0.85))
                linesPath.addLine(to: CGPoint(x: w * 0.75, y: h * 0.85))
                
                context.stroke(linesPath, with: .color(.white), lineWidth: 1.5)
            }
            .frame(width: 36, height: 42)
            
            Text("HALAL")
                .font(.system(size: 9, weight: .black))
                .tracking(1.5)
                .foregroundStyle(.white)
            
            Text("INDONESIA")
                .font(.system(size: 6, weight: .bold))
                .tracking(0.6)
                .foregroundStyle(.white)
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
