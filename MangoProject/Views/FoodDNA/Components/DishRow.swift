//
//  DishRow.swift
//  MangoProject
//
//  Created by Muthiara Putri Aliyu on 10/07/26.
//
//
import SwiftUI

/// A single dish entry. Collapsed, it renders as a plain list row (icon,
/// name, status label) matching a scannable list style. Expanded, it
/// transforms into a colored, bordered card revealing full detail.
struct DishRow: View {
    let dish: DishDisplayModel
    @State private var isExpanded: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    isExpanded.toggle()
                }
            } label: {
                header
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isButton)
            .accessibilityValue(isExpanded ? "Expanded" : "Collapsed")
            .accessibilityHint("Double tap to \(isExpanded ? "collapse" : "see the full analysis")")

            if isExpanded {
                DishRowExpandedContent(dish: dish)
                    .padding(.top, Spacing.small)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(isExpanded ? Spacing.cardPadding : Spacing.small)
        .background(isExpanded ? dish.status.expandedBackground : Color("CardBackground"))
        .overlay {
            if isExpanded {
                RoundedRectangle(cornerRadius: Radius.dishCard)
                    .stroke(dish.status.cardBorder, lineWidth: 1)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: Radius.dishCard))
    }

    private var header: some View {
        HStack(spacing: Spacing.small) {
            ZStack {
                Circle()
                    .fill(isExpanded ? Color("CardBackground") : dish.status.badgeBackground)
                    .frame(width: 36, height: 36)

                Image(systemName: dish.status.iconName)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(dish.status.iconGlyphColor)
            }

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(dish.name)
                    .font(Typography.cardTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(Color("DishTitleText"))

                if isExpanded {
                    DishStatusBadge(status: dish.status)
                } else {
                    Text(dish.status.badgeLabel)
                        .font(Typography.caption)
                        .foregroundStyle(dish.status.accentColor)
                }
            }

            Spacer()

            Image(systemName: "chevron.down")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color("DishBodyText"))
                .rotationEffect(.degrees(isExpanded ? 180 : 0))
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: Spacing.xs) {
            ForEach(DishDisplayModel.mockList) { dish in
                DishRow(dish: dish)
            }
        }
        .padding()
        .background(Color("CardBackground"))
        .clipShape(RoundedRectangle(cornerRadius: Radius.card))
    }
    .background(Color("AppBackground"))
}
