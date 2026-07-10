//
//  DishRow.swift
//  MangoProject
//
//  Created by Muthiara Putri Aliyu on 10/07/26.
//

import SwiftUI

/// A single collapsible dish row. Tapping the chevron/header expands or
/// collapses to reveal DishRowExpandedContent. Expansion state is local
/// to this row — any number of rows can be open at once (no accordion).
struct DishRow: View {
    let dish: DishDisplayModel
    @State private var isExpanded: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Text(dish.name)
                        .font(Typography.cardTitle)
                        .foregroundStyle(Color("TextPrimary"))

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color("TextSecondary"))
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
            }
            .buttonStyle(.plain)

            if isExpanded {
                DishRowExpandedContent(dish: dish)
                    .padding(.top, Spacing.small)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(Spacing.cardPadding)
        .background(backgroundColor)
        .overlay {
            RoundedRectangle(cornerRadius: Radius.card)
                .stroke(borderColor, lineWidth: isExpanded ? 1.5 : 0)
        }
        .clipShape(RoundedRectangle(cornerRadius: Radius.card))
    }

    /// Only tinted with a status color when expanded — matches the mockup,
    /// where collapsed rows are all neutral and only the expanded one
    /// takes on its status color.
    private var backgroundColor: Color {
        guard isExpanded else { return Color("CardBackground") }

        switch dish.status {
        case .halal: return Color("StatusHalalLight").opacity(0.4)
        case .needsVerification: return Color("StatusWarningLight").opacity(0.4)
        case .nonHalal: return Color("StatusDangerLight").opacity(0.4)
        }
    }

    private var borderColor: Color {
        switch dish.status {
        case .halal: return Color("StatusHalalDark")
        case .needsVerification: return Color("StatusWarningDark")
        case .nonHalal: return Color("StatusDangerDark")
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: Spacing.small) {
            ForEach(DishDisplayModel.mockList) { dish in
                DishRow(dish: dish)
            }
        }
        .padding()
    }
    .background(Color("AppBackground"))
}
