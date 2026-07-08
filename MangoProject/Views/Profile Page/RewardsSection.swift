import SwiftUI

/// "Rewards and Benefit" section header + horizontally scrollable reward tiles.
struct RewardsSection: View {
    struct Reward: Identifiable {
        let id = UUID()
        let icon: String
        let title: String
    }

    // Placeholder data — real data will come from a repository/view model.
    let rewards: [Reward] = [
        Reward(icon: "waterbottle.fill", title: "Free Drink"),
        Reward(icon: "percent", title: "Discount"),
        Reward(icon: "gift.fill", title: "B-Day Gift"),
        Reward(icon: "bag.fill", title: "Merchandise")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            NavigationLink {
                Text("All Rewards")
            } label: {
                HStack {
                    Text("Rewards and Benefit")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(rewards) { reward in
                        RewardItem(icon: reward.icon, title: reward.title)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        RewardsSection()
            .padding()
    }
}
