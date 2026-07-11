import SwiftUI

struct CollectPointsButton: View {
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text("Collect Points")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(Color(red: 0.95, green: 0.60, blue: 0.05))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
