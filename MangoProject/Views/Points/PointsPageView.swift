//
//  PointsPageView.swift
//  MangoProject
//

import SwiftUI

struct PointsPageView: View {
    var pointsStore: UserPointsStore = UserPointsStore()
    @State private var isQRScanPresented = false
    @State private var redeemingBenefit: Benefit?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerText
                PointsSummaryCard(
                    points: pointsStore.points,
                    onTapToCollect: { isQRScanPresented = true }
                )
                BenefitsSection(
                    benefits: Benefit.samples,
                    points: pointsStore.points,
                    onRedeem: { redeemingBenefit = $0 }
                )
                RecentActivitySection(items: ActivityItem.samples)
            }
            .padding(.horizontal, Spacing.medium)
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
        .background(Color("AppBackground").ignoresSafeArea())
        .fullScreenCover(isPresented: $isQRScanPresented) {
            QRScannerSheet(
                onCancel: { isQRScanPresented = false },
                onScan: { _ in
                    pointsStore.points += 500
                    isQRScanPresented = false
                }
            )
        }
        .fullScreenCover(item: $redeemingBenefit) { benefit in
            RedeemBenefitQRView(
                benefit: benefit,
                onClose: { redeemingBenefit = nil }
            )
        }
    }

    private var headerText: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            Text("Halal Rewards")
                .font(Typography.screenTitle)
                .foregroundStyle(Color(.textPrimary))

            Text("Earn points by scanning QR at halal restaurants.")
                .font(Typography.bodySecondary)
                .foregroundStyle(Color("TextSecondary"))
        }
    }
}

#Preview {
    PointsPageView()
}
