//
//  ArrivedView.swift
//  MangoProject
//

import SwiftUI

/// Shown once the user gets within arrival range of the destination.
/// Purely presentational — FindingExperienceView decides when to show this
/// and what happens when "Back to Home" is tapped.
struct ArrivedView: View {
    let targetName: String
    var onBackToHome: () -> Void = {}

    var body: some View {
        VStack(spacing: Spacing.large) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color("Accent").opacity(0.15))
                    .frame(width: 160, height: 160)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 88, weight: .bold))
                    .foregroundStyle(Color("Accent"))
            }

            VStack(spacing: Spacing.xs) {
                Text("Welcome, You Have Arrived!")
                    .font(Typography.screenTitle)
                    .foregroundStyle(Color("TextPrimary"))
                    .multilineTextAlignment(.center)

                Text(targetName)
                    .font(Typography.bodySecondary)
                    .foregroundStyle(Color("TextSecondary"))
                    .multilineTextAlignment(.center)

                Text("Bon appétit!")
                    .font(Typography.cardTitle)
                    .foregroundStyle(Color("Accent"))
                    .multilineTextAlignment(.center)
                    .padding(.top, Spacing.xs)
            }

            Spacer()

            Button(action: onBackToHome) {
                Text("Back to Home")
                    .font(Typography.cardTitle)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color("Accent"))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .padding(.horizontal, Spacing.section)
            .padding(.bottom, Spacing.large)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("AppBackground").ignoresSafeArea())
    }
}

#Preview {
    ArrivedView(targetName: "Tamper Coffee")
}
