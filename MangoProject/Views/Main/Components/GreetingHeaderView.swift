//
//  GreetingHeaderView.swift
//  MangoProject
//
//  Created by Muthiara Putri Aliyu on 09/07/26.
//

import SwiftUI

/// The top header of MainView: greeting title, subtitle, and profile button.
/// Purely presentational — takes the display strings and an action closure in,
/// contains no logic of its own.
struct GreetingHeaderView: View {
    let userName: String
    var onProfileTapped: () -> Void = {}

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text("Hello \(userName)!")
                    .font(Typography.screenTitle)
                    .foregroundStyle(Color("TextPrimary"))

                Text("Let's find something halal for your next meal.")
                    .font(Typography.bodySecondary)
                    .foregroundStyle(Color("TextSecondary"))
            }

            Spacer()

            ProfileButton(action: onProfileTapped)
        }
    }
}

#Preview {
    GreetingHeaderView(userName: "Muthi")
        .padding()
        .background(Color("AppBackground"))
}
