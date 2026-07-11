import SwiftUI

struct RestaurantFloatingButtons: View {
    let placeName: String
    let placeURL: String
    let onDismiss: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onDismiss) {
                ZStack {
                    if #available(iOS 26, *) {
                        Circle()
                            .fill(.clear)
                            .glassEffect(in: Circle())
                    } else {
                        Circle()
                            .fill(.ultraThinMaterial)
                    }
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.primary)
                }
                .frame(width: 52, height: 52)
            }
            .buttonStyle(.plain)
            .contentShape(Circle())
            
            Spacer()
            
            ShareLink(item: "Check out \(placeName) on Mango! \(placeURL)") {
                ZStack {
                    if #available(iOS 26, *) {
                        Circle()
                            .fill(.clear)
                            .glassEffect(in: Circle())
                    } else {
                        Circle()
                            .fill(.ultraThinMaterial)
                    }
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.primary)
                }
                .frame(width: 52, height: 52)
            }
            .buttonStyle(.plain)
            .contentShape(Circle())
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}
