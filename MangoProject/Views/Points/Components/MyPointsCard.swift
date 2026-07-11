//
//  MyPointsCard.swift
//  MangoProject
//

import SwiftUI

struct MyPointsCard: View {
    let points: Int
    var onCollect: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("My Points")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white.opacity(0.75))

            HStack(alignment: .center, spacing: 8) {
                Image(systemName: "star.fill")
                    .font(.system(size: 38))
                    .foregroundStyle(Color("AccentStar"))

                Text("\(points)")
                    .font(Typography.screenTitle)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)

                Spacer(minLength: 12)

                Button {
                    onCollect()
                } label: {
                    Label("Collect", systemImage: "star.circle.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color("Accent"))
                        .padding(.horizontal, 16)
                        .frame(height: 44)
                        .background(.white)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color("Accent"))
        )
    }
}
