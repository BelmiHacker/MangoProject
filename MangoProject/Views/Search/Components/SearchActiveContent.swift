import SwiftUI

struct SearchActiveContent: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Recently Searched")
                    .font(.system(size: 22, weight: .bold))
                Spacer()
                Button("Clear") {}
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.secondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .clipShape(Capsule())
                    .disabled(true)
                    .accessibilityLabel("Clear recently searched")
            }
            .padding(.horizontal, 16)
            .padding(.top, 24)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    SearchActiveContent()
}
