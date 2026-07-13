//
//  PointsPageView.swift
//  MangoProject
//

import SwiftUI

struct PointsPageView: View {
    var pointsStore: UserPointsStore = UserPointsStore()
    @State private var isNFCScanPresented = false
    @State private var redeemingBenefit: Benefit?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerText
                PointsSummaryCard(
                    points: pointsStore.points,
                    onTapToCollect: { isNFCScanPresented = true }
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
        .sheet(isPresented: $isNFCScanPresented) {
            NFCScanSheet(
                onCancel: { isNFCScanPresented = false },
                onSuccess: {
                    pointsStore.points += 500
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        isNFCScanPresented = false
                    }
                }
            )
            .presentationDetents([.height(480)])
            .presentationDragIndicator(.hidden)
            .presentationCornerRadius(28)
            .presentationBackground(.clear)
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

            Text("Earn points by tapping NFC at halal restaurants.")
                .font(Typography.bodySecondary)
                .foregroundStyle(Color("TextSecondary"))
        }
    }
}

#Preview {
    PointsPageView()
}
