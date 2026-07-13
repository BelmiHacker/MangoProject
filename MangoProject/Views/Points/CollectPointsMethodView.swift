//
//  CollectPointsMethodView.swift
//  MangoProject
//

import SwiftUI

struct CollectPointsMethodView: View {
    var onCancel: () -> Void = {}
    var onCollected: () -> Void = {}

    @State private var isNFCScanPresented = false
    @State private var isQRScanPresented = false

    private let cardGreen = Color(red: 0.11, green: 0.38, blue: 0.29)

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            header

            VStack(spacing: 14) {
                methodOption(
                    icon: "wave.3.right",
                    title: "Tap NFC",
                    subtitle: "Hold your device near the restaurant's NFC tag",
                    action: { isNFCScanPresented = true }
                )

                methodOption(
                    icon: "qrcode.viewfinder",
                    title: "Scan QR",
                    subtitle: "Scan the QR code at the restaurant's counter",
                    action: { isQRScanPresented = true }
                )
            }

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color("AppBackground").ignoresSafeArea())
        .overlay(alignment: .topTrailing) {
            closeButton
                .padding(.top, 16)
                .padding(.trailing, 20)
        }
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
                    onCollected()
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

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Collect Points")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.primary)

            Text("Choose how you'd like to collect your points")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(.secondary)
        }
        .padding(.trailing, 44)
    }

    private var closeButton: some View {
        Button {
            onCancel()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.secondary)
                .frame(width: 32, height: 32)
                .background(Color(.systemGray5))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Close")
    }

    // MARK: - Method Option

    private func methodOption(icon: String, title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(cardGreen)
                        .frame(width: 52, height: 52)
                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(16)
            .background(Color("CardBackground"))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    CollectPointsMethodView()
}
