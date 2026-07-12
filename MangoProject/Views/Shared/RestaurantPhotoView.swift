//
//  RestaurantPhotoView.swift
//  MangoProject
//

import SwiftUI

/// Shows a restaurant's first available real photo (of up to five slots),
/// otherwise a category-tinted placeholder. Callers are responsible for
/// sizing (`.frame`) and clipping — this view only provides fillable
/// content so it composes into a card strip, a hero banner, or anywhere
/// else a single representative restaurant photo is needed. For the full
/// multi-photo gallery, see `RestaurantPhotoGallery`.
struct RestaurantPhotoView: View {
    let name: String
    let category: String

    var body: some View {
        if let uiImage = RestaurantPhotoAsset.availableImages(for: name).first {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        } else {
            ZStack {
                Color("Accent").opacity(0.85)
                Image(systemName: RestaurantPhotoAsset.categoryIcon(for: category))
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))
            }
        }
    }
}
