import SwiftUI

/// A single stat tile (e.g. Points, Voucher count).
struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    var iconColor: Color = .teal

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(iconColor)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.title3.bold())
                .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

#Preview {
    HStack(spacing: 12) {
        StatCard(icon: "seal", title: "Points", value: "2,450")
        StatCard(icon: "ticket.fill", title: "Voucher", value: "3")
    }
    .padding()
}
