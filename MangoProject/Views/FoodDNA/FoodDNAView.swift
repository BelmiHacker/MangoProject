//
//  FoodDNAView.swift
//  MangoProject
//
//  Created by Muthiara Putri Aliyu on 10/07/26.
//


import SwiftUI

struct FoodDNAView: View {
    @State private var viewModel: FoodDNAViewModel

    init(viewModel: FoodDNAViewModel = FoodDNAViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.section) {
                Text("Food DNA Analysis")
                    .font(Typography.screenTitle)
                    .foregroundStyle(Color("TextPrimary"))

                if viewModel.hasScannedMenu {
                    ScannedMenuImageView(onRetryTapped: {
                        viewModel.resetScan()
                    })

                    FoodDNASummaryCard(status: viewModel.overallStatus)

                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("\(viewModel.dishes.count) Dishes detected")
                            .font(Typography.cardSubtitle)
                            .foregroundStyle(Color("TextSecondary"))

                        VStack(spacing: Spacing.small) {
                            ForEach(viewModel.dishes) { dish in
                                DishRow(dish: dish)
                            }
                        }
                    }
                } else {
                    EmptyScanStateView(onScanTapped: {
                        viewModel.startScan()
                    })
                }
            }
            .padding(Spacing.medium)
        }
        .background(Color("AppBackground"))
    }
}

#Preview("Scanned — all halal") {
    let viewModel = FoodDNAViewModel()
    viewModel.dishes = [DishDisplayModel.mockList[0]]
    return FoodDNAView(viewModel: viewModel)
}

#Preview("Empty — pre-scan") {
    let viewModel = FoodDNAViewModel()
    viewModel.resetScan()
    return FoodDNAView(viewModel: viewModel)
}
