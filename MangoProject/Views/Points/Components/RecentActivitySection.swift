//
//  RecentActivitySection.swift
//  MangoProject
//

import SwiftUI

struct ActivityItem: Identifiable {
    let id: Int
    let placeName: String
    let points: Int

    var isEarn: Bool { points > 0 }

    var pointsText: String {
        points > 0 ? "+\(points) pts" : "\(points) pts"
    }

    static let samples: [ActivityItem] = [
        .init(id: 0, placeName: "Almaz Chicken", points: 12),
        .init(id: 1, placeName: "Redeem Point Almaz Chicken", points: -12),
        .init(id: 2, placeName: "Almaz Chicken", points: 12),
        .init(id: 3, placeName: "Redeem Point Almaz Chicken", points: -12),
        .init(id: 4, placeName: "Almaz Chicken", points: 12),
    ]
}

struct RecentActivitySection: View {
    let items: [ActivityItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Activity")
                .font(Typography.sectionHeader)
                .foregroundStyle(Color(.textPrimary))


            VStack(spacing: 0) {
                ForEach(items) { item in
                    ActivityRow(item: item)

                    if item.id != items.last?.id {
                        Divider()
                            .padding(.leading, 68)
                    }
                }
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}

private struct ActivityRow: View {
    let item: ActivityItem

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(item.isEarn
                          ? Color(red: 0.11, green: 0.38, blue: 0.29).opacity(0.12)
                          : Color.red.opacity(0.10))
                    .frame(width: 44, height: 44)

                Image(systemName: "fork.knife")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(item.isEarn
                                     ? Color(red: 0.11, green: 0.38, blue: 0.29)
                                     : .red)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(item.placeName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.primary)

                Text(item.pointsText)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(item.isEarn ? Color(red: 0.11, green: 0.38, blue: 0.29) : .red)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
