import SwiftUI

/// Promo card with an image background, bottom gradient scrim, badge, title and description.
///
/// `imageName` is optional on purpose: pass an asset name once real artwork exists,
/// otherwise a neutral gradient placeholder is shown so this compiles/previews standalone.
struct FeaturedCard: View {
    let badge: String
    let title: String
    let description: String
    var imageName: String? = nil

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            background

            LinearGradient(
                colors: [.black.opacity(0.8), .black.opacity(0.05)],
                startPoint: .bottom,
                endPoint: .top
            )

            VStack(alignment: .leading, spacing: 6) {
                Text(badge)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.orange.gradient, in: Capsule())
                    .foregroundStyle(.white)

                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)

                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.85))
            }
            .padding()
        }
        .frame(height: 160)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    @ViewBuilder
    private var background: some View {
        if let imageName {
            Image(imageName)
                .resizable()
                .scaledToFill()
        } else {
            LinearGradient(
                colors: [Color.black, Color(.systemGray5)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

#Preview {
    FeaturedCard(
        badge: "Premium Experience",
        title: "Exclusive Halal Lounge Access",
        description: "Redeem 5,000 points for a night of luxury dining."
    )
    .padding()
}
