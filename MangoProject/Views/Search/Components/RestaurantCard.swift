import SwiftUI

struct RestaurantCard: View {
    let place: NearbyFoodPlace
    var onDirections: () -> Void = {}

    private let accent = Color(red: 0.18, green: 0.42, blue: 0.35)

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            placeImage
            infoStack
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }

    private var placeImage: some View {
        ZStack {
            Color(.systemGray5)
            Image(systemName: "fork.knife")
                .font(.system(size: 28, weight: .regular))
                .foregroundStyle(Color(.systemGray2))
        }
        .frame(width: 80, height: 80)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var infoStack: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(place.name)
                .font(.system(size: 16, weight: .bold))
                .lineLimit(2)

            Text("\(place.category) · \(place.distanceText)")
                .font(.system(size: 13))
                .foregroundStyle(Color.secondary)

            HStack {
                Spacer()
                directionsButton
            }
        }
    }

    private var directionsButton: some View {
        Button(action: onDirections) {
            Label("Directions", systemImage: "location.fill")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(accent)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Get directions to \(place.name)")
    }
}
