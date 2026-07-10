//
//  PointsPageView.swift
//  MangoProject
//

import SwiftUI

struct PointsPageView: View {
    @State private var isNFCScanPresented = false
    @State private var isQRScanPresented = false
    @State private var points = 67

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerText
                MyPointsCard(
                    points: points,
                    onTapToCollect: { isNFCScanPresented = true },
                    onScanQR: { isQRScanPresented = true }
                )
                BenefitsSection(benefits: Benefit.samples)
                RecentActivitySection(items: ActivityItem.samples)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
        .background(Color("AppBackground").ignoresSafeArea())
        .preferredColorScheme(.light)
        .fullScreenCover(isPresented: $isQRScanPresented) {
            QRScannerSheet(
                onCancel: { isQRScanPresented = false },
                onScan: { _ in isQRScanPresented = false }
            )
        }
        .sheet(isPresented: $isNFCScanPresented) {
            NFCScanSheet(
                onCancel: { isNFCScanPresented = false },
                onSuccess: {
                    points += 500
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
    }

    private var headerText: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Halal Rewards")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(.primary)

            Text("Earn points by tapping NFC at participating Halal Restaurant")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    PointsPageView()
}
