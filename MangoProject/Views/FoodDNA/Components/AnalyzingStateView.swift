//
//  AnalyzingStateView.swift
//  MangoProject
//
//  Created by Muthiara Putri Aliyu on 11/07/26.
//


import SwiftUI

/// Shown while the menu photo is being analyzed by the backend.
struct AnalyzingStateView: View {
    var body: some View {
        VStack(spacing: Spacing.medium) {
            ProgressView()
                .scaleEffect(1.3)

            Text("Analyzing your menu...")
                .font(Typography.bodySecondary)
                .foregroundStyle(Color("TextSecondary"))
        }
        .padding(Spacing.section)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    AnalyzingStateView()
        .padding()
        .background(Color("AppBackground"))
}
