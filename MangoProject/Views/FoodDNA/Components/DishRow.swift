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
    var isLastRow: Bool = false
    @State private var isExpanded: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                header
            }
            .buttonStyle(.plain)

            if isExpanded {
                DishRowExpandedContent(dish: dish)
                    .padding(.top, Spacing.small)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }

            if !isExpanded && !isLastRow {
                Divider()
                    .padding(.top, Spacing.small)
            }
        }
        .padding(isExpanded ? Spacing.cardPadding : 0)
        .padding(.top, isExpanded ? 0 : Spacing.small)
        .background(isExpanded ? tintColor : Color.clear)
        .overlay {
            if isExpanded {
                RoundedRectangle(cornerRadius: Radius.card)
                    .stroke(darkColor, lineWidth: 1.5)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: Radius.card))
    }

    private var header: some View {
        HStack(spacing: Spacing.small) {
            ZStack {
                Circle()
                    .fill(isExpanded ? .white.opacity(0.6) : tintColor)
                    .frame(width: 36, height: 36)

                Image(systemName: dish.status.iconName)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(darkColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(dish.name)
                    .font(Typography.cardTitle)
                    .foregroundStyle(Color("TextPrimary"))

                if !isExpanded {
                    Text(dish.status.listStatusLabel)
                        .font(Typography.caption)
                        .foregroundStyle(darkColor)
                }
            }

            Spacer()

            Image(systemName: "chevron.down")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color("TextSecondary"))
                .rotationEffect(.degrees(isExpanded ? 180 : 0))
        }
    }

    private var darkColor: Color {
        switch dish.status {
        case .halal: return Color("StatusHalalDark")
        case .needsVerification: return Color("StatusWarningDark")
        case .nonHalal: return Color("StatusDangerDark")
        }
    }

    private var tintColor: Color {
        switch dish.status {
        case .halal: return Color("StatusHalalLight")
        case .needsVerification: return Color("StatusWarningLight")
        case .nonHalal: return Color("StatusDangerLight")
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 0) {
            ForEach(Array(DishDisplayModel.mockList.enumerated()), id: \.element.id) { index, dish in
                DishRow(dish: dish, isLastRow: index == DishDisplayModel.mockList.count - 1)
            }
        }
        .padding()
        .background(Color("CardBackground"))
        .clipShape(RoundedRectangle(cornerRadius: Radius.card))
    }
    .background(Color("AppBackground"))
}
