import SwiftUI

struct OffersSectionView: View {
    @State private var selectedOffer: OfferDisplayModel?

    let offers = [
        OfferDisplayModel(
            id: "1",
            title: "50% OFF",
            subtitle: "All signature drinks",
            restaurant: "Kopi Kenangan",
            gradient: LinearGradient(colors: [Color.orange.opacity(0.8), Color.red.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing),
            iconName: "cup.and.saucer.fill"
        ),
        OfferDisplayModel(
            id: "2",
            title: "BUY 1 GET 1",
            subtitle: "Mie Yamin Special",
            restaurant: "Mie Bandung Kejaksaan 1964",
            gradient: LinearGradient(colors: [Color.blue.opacity(0.8), Color.indigo.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing),
            iconName: "fork.knife.circle.fill"
        ),
        OfferDisplayModel(
            id: "3",
            title: "FREE DESSERT",
            subtitle: "Min. spend Rp 100k",
            restaurant: "Luuca",
            gradient: LinearGradient(colors: [Color.purple.opacity(0.8), Color.pink.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing),
            iconName: "birthday.cake.fill"
        ),
        OfferDisplayModel(
            id: "4",
            title: "20% OFF",
            subtitle: "All dimsum menu",
            restaurant: "Su Wah",
            gradient: LinearGradient(colors: [Color.green.opacity(0.8), Color.teal.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing),
            iconName: "leaf.fill"
        )
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            Text("Offers")
                .font(Typography.sectionHeader)
                .foregroundStyle(Color("TextPrimary"))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.medium) {
                    ForEach(offers) { offer in
                        Button(action: {
                            selectedOffer = offer
                        }) {
                            OfferCardView(offer: offer)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, Spacing.medium)
                .padding(.bottom, 8)
            }
            .padding(.horizontal, -Spacing.medium)
        }
        .sheet(item: $selectedOffer) { offer in
            OfferQRCodeSheet(
                restaurantName: offer.restaurant,
                onDismiss: { selectedOffer = nil }
            )
        }
    }
}

struct OfferDisplayModel: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let restaurant: String
    let gradient: LinearGradient
    let iconName: String
}

struct OfferCardView: View {
    let offer: OfferDisplayModel

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background
            offer.gradient
            
            // Decorative background icon
            VStack {
                HStack {
                    Spacer()
                    Image(systemName: offer.iconName)
                        .font(.system(size: 80))
                        .foregroundStyle(.white.opacity(0.15))
                        .padding(.top, -10)
                        .padding(.trailing, -20)
                }
                Spacer()
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                // Badge
                Text(offer.title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.25))
                    .clipShape(Capsule())
                    .padding(.bottom, 8)
                
                Text(offer.subtitle)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
                
                HStack {
                    Text(offer.restaurant)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white.opacity(0.9))
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.white)
                }
            }
            .padding(16)
        }
        .frame(width: 260, height: 160)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .appShadow(Shadow.card)
    }
}

#Preview {
    OffersSectionView()
        .padding()
        .background(Color("AppBackground"))
}
