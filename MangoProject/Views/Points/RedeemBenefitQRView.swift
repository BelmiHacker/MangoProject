//
//  RedeemBenefitQRView.swift
//  MangoProject
//

import CoreImage.CIFilterBuiltins
import SwiftUI

struct RedeemBenefitQRView: View {
    let benefit: Benefit
    var onClose: () -> Void = {}

    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()

    var body: some View {
        VStack(spacing: 32) {
            header

            VStack(spacing: 16) {
                Image(uiImage: qrImage)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 220, height: 220)
                    .padding(20)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(Color("AccentStar"))
                    Text("\(benefit.pointsCost) points")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.secondary)
                }

                Text("Show this to the cashier to redeem")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)

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
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(benefit.title)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.primary)

            Text(benefit.subtitle)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.trailing, 44)
    }

    private var closeButton: some View {
        Button {
            onClose()
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

    // MARK: - QR Generation

    private var qrImage: UIImage {
        let payload = "MANGOPROJECT-BENEFIT-\(benefit.id)"
        filter.message = Data(payload.utf8)

        guard let outputImage = filter.outputImage else {
            return UIImage(systemName: "qrcode") ?? UIImage()
        }

        let transformed = outputImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
        guard let cgImage = context.createCGImage(transformed, from: transformed.extent) else {
            return UIImage(systemName: "qrcode") ?? UIImage()
        }

        return UIImage(cgImage: cgImage)
    }
}

#Preview {
    RedeemBenefitQRView(benefit: Benefit.samples[0])
}
