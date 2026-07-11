//
//  ErrorStateView.swift
//  MangoProject
//
//  Created by Muthiara Putri Aliyu on 11/07/26.
//

import SwiftUI

/// Shown when a menu analysis attempt fails. Offers a retry action.
struct ErrorStateView: View {
    let message: String
    var onRetryTapped: () -> Void = {}

    var body: some View {
        VStack(spacing: Spacing.medium) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundStyle(Color("StatusDangerDark"))

            Text(message)
                .font(Typography.bodySecondary)
                .foregroundStyle(Color("TextPrimary"))
                .multilineTextAlignment(.center)

            Button(action: onRetryTapped) {
                Text("Try Again")
                    .font(Typography.cardTitle)
                    .foregroundStyle(.white)
                    .padding(.horizontal, Spacing.large)
                    .padding(.vertical, Spacing.small)
                    .background(Color("StatusDangerDark"))
                    .clipShape(Capsule())
            }
        }
        .padding(Spacing.section)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ErrorStateView(message: "We couldn't analyze this menu. Please try again.")
        .padding()
        .background(Color("AppBackground"))
}
