import SwiftUI

/// Profile tab content. Assembles the header, stats, CTA, rewards, and featured sections.
/// No business logic or networking here — placeholder data only.
struct ProfileView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ProfileHeaderCard(
                    name: "Muthi",
                    tier: "Gold Tier",
                    expiryText: "Until Dec 2026"
                )

                HStack(spacing: 12) {
                    StatCard(icon: "seal", title: "Points", value: "2,450")
                    StatCard(icon: "ticket.fill", title: "Voucher", value: "3")
                }

                CollectPointsButton()

                RewardsSection()

                FeaturedCard(
                    badge: "Premium Experience",
                    title: "Exclusive Halal Lounge Access",
                    description: "Redeem 5,000 points for a night of luxury dining."
                )
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    // back navigation handled by NavigationStack in real usage
                } label: {
                    Image(systemName: "chevron.left")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    // present more options
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
}
