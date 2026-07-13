//
//  FoodDNAView.swift
//  MangoProject
//
//  Created by Muthiara Putri Aliyu on 10/07/26.
//

//
//  FoodDNAView.swift
//  MangoProject
//
//  Views/FoodDNA
//

import SwiftUI
import PhotosUI

struct FoodDNAView: View {
    @State private var viewModel: FoodDNAViewModel
    @State private var selectedItem: PhotosPickerItem?
    @State private var isShowingCamera = false

    init(viewModel: FoodDNAViewModel = FoodDNAViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.section) {
                Text("Food DNA Analysis")
                    .font(Typography.screenTitle)
                    .foregroundStyle(Color("TextPrimary"))

                content
            }
            .padding(Spacing.medium)
        }
        .background(Color("AppBackground"))
        .onChange(of: selectedItem) { _, newItem in
            Task {
                guard let data = try? await newItem?.loadTransferable(type: Data.self),
                      let image = UIImage(data: data) else { return }
                await viewModel.analyzeMenu(image: image)
            }
        }
        .fullScreenCover(isPresented: $isShowingCamera) {
            CameraPicker { image in
                Task { await viewModel.analyzeMenu(image: image) }
            }
            .ignoresSafeArea()
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isAnalyzing {
            AnalyzingStateView()
        } else if let errorMessage = viewModel.errorMessage {
            ErrorStateView(message: errorMessage, onRetryTapped: {
                viewModel.resetScan()
            })
        } else if viewModel.hasScannedMenu {
            ScannedMenuImageView(image: viewModel.scannedImage, onRetryTapped: {
                viewModel.resetScan()
            })

            FoodDNASummaryCard(status: viewModel.overallStatus)

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("\(viewModel.dishes.count) Dishes detected")
                    .font(Typography.cardSubtitle)
                    .foregroundStyle(Color("TextSecondary"))

                VStack(spacing: 0) {
                    ForEach(Array(viewModel.dishes.enumerated()), id: \.element.id) { index, dish in
                        DishRow(dish: dish, isLastRow: index == viewModel.dishes.count - 1)
                    }
                }
                .padding(Spacing.small)
                .background(Color("CardBackground"))
                .clipShape(RoundedRectangle(cornerRadius: Radius.card))
            }
        } else {
            EmptyScanStateView(
                selectedItem: $selectedItem,
                onTakePhotoTapped: { isShowingCamera = true }
            )
        }
    }
}

#Preview("Empty — pre-scan") {
    FoodDNAView()
}

#Preview("Loading") {
    let viewModel = FoodDNAViewModel()
    viewModel.isAnalyzing = true
    return FoodDNAView(viewModel: viewModel)
}

#Preview("Error") {
    let viewModel = FoodDNAViewModel()
    viewModel.errorMessage = "We couldn't analyze this menu. Please try again."
    return FoodDNAView(viewModel: viewModel)
}

#Preview("Scanned result") {
    let viewModel = FoodDNAViewModel()
    viewModel.dishes = DishDisplayModel.mockList
    viewModel.hasScannedMenu = true
    return FoodDNAView(viewModel: viewModel)
}
