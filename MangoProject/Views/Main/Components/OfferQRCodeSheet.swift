import SwiftUI
import Combine

struct OfferQRCodeSheet: View {
    let restaurantName: String
    let onDismiss: () -> Void
    
    @State private var timeRemaining = 180 // 3 minutes in seconds
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 32) {
            // Close Button
            HStack {
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(Color("TextSecondary"))
                }
            }
            .padding(.top, 16)
            .padding(.trailing, 16)
            
            Spacer()
            
            VStack(spacing: 24) {
                // Restaurant Name
                Text(restaurantName)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color("TextPrimary"))
                    .multilineTextAlignment(.center)
                
                // QR Code Image
                Image(restaurantName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                
                // Countdown Timer
                VStack(spacing: 8) {
                    Text("Expires in")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color("TextSecondary"))
                    
                    Text(timeString(time: timeRemaining))
                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color.red.opacity(0.8))
                }
            }
            
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("AppBackground"))
        .onReceive(timer) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            }
        }
    }
    
    // Helper to format time
    private func timeString(time: Int) -> String {
        let minutes = time / 60
        let seconds = time % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    OfferQRCodeSheet(restaurantName: "Kopi Kenangan", onDismiss: {})
}
