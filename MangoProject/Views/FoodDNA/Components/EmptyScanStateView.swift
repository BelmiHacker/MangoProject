//
//  EmptyScanStateView.swift
//  MangoProject
//
//  Created by Muthiara Putri Aliyu on 10/07/26.
//


import SwiftUI

/// Shown when no menu has been scanned yet — the screen's default/reset state.
/// Purely presentational; FoodDNAView supplies the scan action.
struct EmptyScanStateView: View {
    var onScanTapped: () -> Void = {}

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

            Button(action: onScanTapped) {
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
    EmptyScanStateView()
        .padding()
        .background(Color("AppBackground"))
}
