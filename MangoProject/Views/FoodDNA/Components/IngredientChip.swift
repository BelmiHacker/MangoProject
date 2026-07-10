//
//  IngredientChip.swift
//  MangoProject
//
//  Created by Muthiara Putri Aliyu on 10/07/26.
//


import SwiftUI

/// Small pill showing a single detected ingredient, e.g. "Flour", "Pork Bacon".
/// Purely presentational — no logic, no tap action.
struct IngredientChip: View {
    let name: String

    var body: some View {
        Text(name)
            .font(Typography.caption)
            .foregroundStyle(Color("TextPrimary"))
            .padding(.horizontal, Spacing.small)
            .padding(.vertical, Spacing.xs)
            .background(Color("CardBackground"))
            .clipShape(Capsule())
    }
}

#Preview {
    HStack {
        IngredientChip(name: "Flour")
        IngredientChip(name: "Carrot")
        IngredientChip(name: "Pork Bacon")
    }
    .padding()
    .background(Color("AppBackground"))
}
