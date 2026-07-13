//
//  PointsPageView.swift
//  MangoProject
//

import SwiftUI

struct PointsPageView: View {
    @State private var isCollectMethodPresented = false
    @State private var redeemingBenefit: Benefit?
    @State private var points = 67

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerText
                MyPointsCard(
                    points: points
                )
                BenefitsSection(
                    benefits: Benefit.samples,
                    points: points,
                    onRedeem: { redeemingBenefit = $0 }
                )
                RecentActivitySection(items: ActivityItem.samples)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
        .background(Color("AppBackground").ignoresSafeArea())
        .fullScreenCover(isPresented: $isCollectMethodPresented) {
            CollectPointsMethodView(
                onCancel: { isCollectMethodPresented = false },
                onCollected: { points += 500 }
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
        VStack(alignment: .leading, spacing: 6) {
            Text("Halal Rewards")
                .font(Typography.screenTitle)
                .foregroundStyle(Color(.textPrimary))

            Text("Earn points by tapping NFC at participating Halal Restaurant")
                .font(Typography.bodySecondary)
                .foregroundStyle(Color("TextSecondary"))
        }
    }
}

#Preview {
    PointsPageView()
}
