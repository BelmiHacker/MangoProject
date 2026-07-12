import SwiftUI

/// Horizontal gallery of a restaurant's real photos (up to five). Shows a
/// single category-tinted placeholder tile when none have been uploaded
/// yet, instead of a row of empty boxes.
struct RestaurantPhotoScroll: View {
    let name: String
    let category: String

    var body: some View {
        let images = RestaurantPhotoAsset.availableImages(for: name)

        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                if images.isEmpty {
                    placeholderTile
                } else {
                    ForEach(Array(images.enumerated()), id: \.offset) { _, uiImage in
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 110)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }

    private var placeholderTile: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color("Accent").opacity(0.85))
            Image(systemName: RestaurantPhotoAsset.categoryIcon(for: category))
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.white.opacity(0.9))
        }
        .frame(width: 100, height: 110)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
