//
//  DishRowExpandedContent.swift
//  MangoProject
//
//  Created by Muthiara Putri Aliyu on 10/07/26.
//

import SwiftUI

/// The content shown inside a DishRow when expanded. Layout differs by
/// status: halal dishes show a plain summary sentence; needsVerification
/// and nonHalal dishes show detected ingredients + potential concerns.
struct DishRowExpandedContent: View {
    let dish: DishDisplayModel

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            switch dish.status {
            case .halal:
                if let summaryText = dish.summaryText {
                    Text(summaryText)
                        .font(Typography.bodySecondary)
                        .foregroundStyle(Color("TextSecondary"))
                }

            case .needsVerification, .nonHalal:
                Text("Detected ingredients:")
                    .font(Typography.cardSubtitle)
                    .foregroundStyle(Color("TextSecondary"))

                FlowLayoutChips(ingredients: dish.detectedIngredients)

                if !dish.concerns.isEmpty {
                    Text("Potential concerns:")
                        .font(Typography.cardSubtitle)
                        .foregroundStyle(Color("TextSecondary"))
                        .padding(.top, Spacing.xs)

                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        ForEach(dish.concerns, id: \.self) { concern in
                            ConcernRow(text: concern, status: dish.status)
                        }
                    }
                }

                Text("Please confirm with the restaurant staff for more accurate information.")
                    .font(Typography.caption)
                    .foregroundStyle(Color("TextSecondary"))
                    .padding(.top, Spacing.xs)
            }
        }
    }
}

/// Simple wrapping row of ingredient chips. Uses a basic HStack that wraps
/// via multiple rows rather than a true flow layout, since SwiftUI's native
/// Layout protocol flow wrapping would be a bigger addition than this
/// UI-only phase calls for. Fine for short ingredient lists like these.
private struct FlowLayoutChips: View {
    let ingredients: [String]

    var body: some View {
        // Simple 2-column-ish wrap using a LazyVGrid, adaptive width.
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 80), spacing: Spacing.xs)],
            alignment: .leading,
            spacing: Spacing.xs
        ) {
            ForEach(ingredients, id: \.self) { ingredient in
                IngredientChip(name: ingredient)
            }
        }
    }
}

#Preview {
    VStack(spacing: Spacing.medium) {
        DishRowExpandedContent(dish: DishDisplayModel.mockList[0])
        Divider()
        DishRowExpandedContent(dish: DishDisplayModel.mockList[1])
        Divider()
        DishRowExpandedContent(dish: DishDisplayModel.mockList[2])
    }
    .padding()
    .background(Color("AppBackground"))
}
