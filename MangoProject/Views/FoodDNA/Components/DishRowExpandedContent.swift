//
//  DishRowExpandedContent.swift
//  MangoProject
//
//  Created by Muthiara Putri Aliyu on 10/07/26.
//

import SwiftUI

/// The content shown inside a DishRow when expanded. Always structured the
/// same way regardless of status — why the model reached this status, and
/// the ingredients it detected — so every card carries the same depth of detail.
struct DishRowExpandedContent: View {
    let dish: DishDisplayModel

    /// The model's reason for this status. Stored as `summaryText` for
    /// halal dishes and as the sole `concerns` entry otherwise — same
    /// underlying "why" data, just shaped differently by the mapping layer.
    private var reasonText: String {
        dish.summaryText ?? dish.concerns.first ?? "No explanation was provided for this dish."
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                ExpandedSectionHeader(
                    icon: dish.status.iconName,
                    title: dish.status.reasonSectionTitle,
                    tint: dish.status.accentColor
                )
                Text(reasonText)
                    .font(Typography.bodySecondary)
                    .foregroundStyle(Color("DishBodyText"))
            }

            if !dish.detectedIngredients.isEmpty {
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    ExpandedSectionHeader(
                        icon: "list.bullet",
                        title: "Detected ingredients",
                        tint: dish.status.accentColor
                    )
                    FlowLayoutChips(ingredients: dish.detectedIngredients)
                }
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
