import SwiftUI

struct RestaurantActionButtons: View {
    let onDirectionsTap: () -> Void
    let onCallTap: () -> Void
    let onSaveTap: () -> Void
    
    var body: some View {
        HStack(spacing: 10) {
            // Directions
            Button(action: onDirectionsTap) {
                HStack(spacing: 6) {
                    Image(systemName: "safari")
                        .font(.system(size: 15, weight: .bold))
                    Text("Directions")
                        .font(.system(size: 15, weight: .bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(Color(red: 0.05, green: 0.35, blue: 0.33))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
            
            // Call
            Button(action: onCallTap) {
                HStack(spacing: 6) {
                    Image(systemName: "phone.fill")
                        .font(.system(size: 13))
                    Text("Call")
                        .font(.system(size: 15, weight: .bold))
                }
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
            
            // Save
            Button(action: onSaveTap) {
                HStack(spacing: 6) {
                    Image(systemName: "bookmark")
                        .font(.system(size: 13))
                    Text("Save")
                        .font(.system(size: 15, weight: .bold))
                }
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
        }
    }
}
