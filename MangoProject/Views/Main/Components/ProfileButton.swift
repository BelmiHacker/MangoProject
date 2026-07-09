//
//  ProfileButton.swift
//  MangoProject
//
//  Created by Muthiara Putri Aliyu on 09/07/26.
//


import SwiftUI

/// The circular profile icon shown in the top-right of MainView's header.
/// Purely presentational — navigation to the Profile screen will be wired
/// in by whoever owns navigation, via the `action` closure.
struct ProfileButton: View {
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 32))
                .foregroundStyle(Color("TextPrimary"), Color("CardBackground"))
        }
        .accessibilityLabel("Profile")
    }
}

#Preview {
    ProfileButton()
        .padding()
        .background(Color("AppBackground"))
}
