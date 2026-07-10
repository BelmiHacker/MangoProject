//
//  ScannedMenuImageView.swift
//  MangoProject
//
//  Created by Muthiara Putri Aliyu on 10/07/26.
//


import SwiftUI

/// Displays the scanned menu photo at the top of the Food DNA screen,
/// with a retry/remove button. Purely presentational — FoodDNAView decides
/// what happens when the button is tapped (resets to the empty pre-scan state).
struct ScannedMenuImageView: View {
    var onRetryTapped: () -> Void = {}

    var body: some View {
        RoundedRectangle(cornerRadius: Radius.card)
            .fill(Color("TextSecondary").opacity(0.15))
            .frame(height: 220)
            .frame(maxWidth: .infinity)
            .overlay {
                Image(systemName: "photo")
                    .font(.system(size: 32))
                    .foregroundStyle(Color("TextSecondary"))
            }
            .overlay(alignment: .topTrailing) {
                Button(action: onRetryTapped) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.primary)
                        .frame(width: 44, height: 44)
                        .background(.regularMaterial, in: Circle())
                }
                .padding(Spacing.xs)
                .accessibilityLabel("Remove scanned menu and start over")
            }
    }
}

#Preview {
    ScannedMenuImageView()
        .padding()
        .background(Color("AppBackground"))
}
