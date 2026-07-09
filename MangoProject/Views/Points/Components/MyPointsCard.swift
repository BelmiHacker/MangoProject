//
//  MyPointsCard.swift
//  MangoProject
//

import SwiftUI

struct MyPointsCard: View {
    let points: Int
    var onTapToCollect: () -> Void = {}
    var onScanQR: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 10) {
                Text("My Points")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.75))

                HStack(alignment: .center, spacing: 8) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 38))
                        .foregroundStyle(.yellow)

                    Text("\(points)")
                        .font(.system(size: 52, weight: .bold))
                        .foregroundStyle(.white)
                }
            }

            HStack(spacing: 10) {
                Button(action: onTapToCollect) {
                    HStack(spacing: 6) {
                        Image(systemName: "wave.3.right")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Tap To Collect")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundStyle(Color(red: 0.11, green: 0.38, blue: 0.29))
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(.white)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)

                Button(action: onScanQR) {
                    HStack(spacing: 6) {
                        Image(systemName: "qrcode.viewfinder")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Scan QR")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundStyle(Color(red: 0.11, green: 0.38, blue: 0.29))
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(.white)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(red: 0.11, green: 0.38, blue: 0.29))
        )
    }
}
