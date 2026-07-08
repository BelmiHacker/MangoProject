import SwiftUI

/// Top identity card: avatar, greeting, tier badge, and membership expiry.
struct ProfileHeaderCard: View {
    let name: String
    let tier: String
    let expiryText: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
                .foregroundStyle(.teal)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 6) {
                Text("Hello, \(name)!")
                    .font(.headline)

                HStack(spacing: 8) {
                    Label(tier, systemImage: "star.fill")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.colorTag, in: Capsule())
                        .foregroundStyle(.white)

                    Text(expiryText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 0)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

#Preview {
    ProfileHeaderCard(name: "Muthi", tier: "Gold Tier", expiryText: "Until Dec 2026")
        .padding()
}
