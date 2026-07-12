//
//  ExplorePhotoViewer.swift
//  MangoProject
//

import SwiftUI

struct SelectedPhoto: Identifiable {
    let id = UUID()
    let image: UIImage
}

struct ExplorePhotoViewer: View {
    let photo: SelectedPhoto
    var onClose: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()

            Image(uiImage: photo.image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
                    .background(.black.opacity(0.4))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close")
            .padding(.top, 16)
            .padding(.trailing, 16)
        }
    }
}
