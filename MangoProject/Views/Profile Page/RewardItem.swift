import SwiftUI

/// A single reward: rounded-square icon tile + title, used inside the horizontal rewards rail.
struct RewardItem: View {
    let icon: String
    let title: String

    var body: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.colorTag.gradient)
                .frame(width: 56, height: 56)
                .overlay {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundStyle(.white)
                }

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
        }
        .frame(width: 72)
    }
}

#Preview {
    HStack(spacing: 16) {
        RewardItem(icon: "waterbottle.fill", title: "Free Drink")
        RewardItem(icon: "gift.fill", title: "B-Day Gift")
    }
    .padding()
}
