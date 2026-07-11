//
//  EmptyScanStateView.swift
//  MangoProject
//
//  Created by Muthiara Putri Aliyu on 10/07/26.
//
//
//  EmptyScanStateView.swift
//  MangoProject
//
//  Views/FoodDNA/Components
//

import SwiftUI
import PhotosUI

/// Shown when no menu has been scanned yet. Offers Take Photo / Choose
/// from Library via a menu, matching standard iOS image-picking UX.
struct EmptyScanStateView: View {
    @Binding var selectedItem: PhotosPickerItem?
    var onTakePhotoTapped: () -> Void = {}

    var body: some View {
        VStack(spacing: Spacing.medium) {
            Image(systemName: "viewfinder")
                .font(.system(size: 40))
                .foregroundStyle(Color("TextSecondary"))

            VStack(spacing: Spacing.xs) {
                Text("No menu scanned yet")
                    .font(Typography.cardTitle)
                    .foregroundStyle(Color("TextPrimary"))

                Text("Scan a menu to see its Food DNA analysis.")
                    .font(Typography.bodySecondary)
                    .foregroundStyle(Color("TextSecondary"))
                    .multilineTextAlignment(.center)
            }

            Menu {
                Button(action: onTakePhotoTapped) {
                    Label("Take Photo", systemImage: "camera")
                }

                PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                    Label("Choose from Library", systemImage: "photo.on.rectangle")
                }
            } label: {
                Text("Scan Menu")
                    .font(Typography.cardTitle)
                    .foregroundStyle(.white)
                    .padding(.horizontal, Spacing.large)
                    .padding(.vertical, Spacing.small)
                    .background(Color("Accent"))
                    .clipShape(Capsule())
            }
        }
        .padding(Spacing.section)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    EmptyScanStateView(selectedItem: .constant(nil))
        .padding()
        .background(Color("AppBackground"))
}
