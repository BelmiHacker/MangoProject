import SwiftUI

/// Primary CTA. Business logic (NFC / networking) is intentionally left to the caller via `action`.
struct CollectPointsButton: View {
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            Label("Collect Points", systemImage: "creditcard.fill")
                .font(.headline)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .tint(Color.colorButton)
        .controlSize(.large)
    }
}

#Preview {
    CollectPointsButton()
        .padding()
}
