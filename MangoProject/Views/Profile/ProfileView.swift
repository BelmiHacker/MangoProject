//
//  ProfileView.swift
//  MangoProject
//
//  Views/Profile
//

import SwiftUI

/// The user's account/profile screen, reachable by tapping the profile
/// button in MainView's header. Matches the "Akun Yaqeen" design spec.
///
/// Behaviour notes:
/// - "Informasi Personal" is clickable but doesn't navigate anywhere yet.
/// - "Points" navigates to `PointsPageView`.
/// - "Resto Favorit" expands/collapses to reveal favourite restaurant cards.
/// - "Log Out" stays below the favourite restaurants even when expanded.
struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss

    var onNavigateToPoints: (() -> Void)? = nil

    /// Controls the expand/collapse state of the favourite restaurants section.
    @State private var isFavoritesExpanded = false

    // MARK: - Mock data (matches screenshot text exactly)

    private let userName = "Muthi"
    private let userEmail = "MuthiHappySelalu06@gmail.com"

    private let favoriteRestaurants: [FavoriteRestaurant] = [
        FavoriteRestaurant(name: "Pesta Kebun - The Breeze", iconName: "pestaKebunIcon", iconColor: Color(red: 0.93, green: 0.91, blue: 0.85)),
        FavoriteRestaurant(name: "All Ace - Maggiore", iconName: "allAceIcon", iconColor: .white),
        FavoriteRestaurant(name: "Subway - The Breeze", iconName: "subwayIcon", iconColor: Color(red: 0.16, green: 0.55, blue: 0.28)),
        FavoriteRestaurant(name: "Starbucks - The Breeze", iconName: "starbucksIcon", iconColor: Color(red: 0.0, green: 0.40, blue: 0.24)),
        FavoriteRestaurant(name: "Marugame Udon - AEON", iconName: "marugameIcon", iconColor: Color(red: 0.85, green: 0.12, blue: 0.10)),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.section) {
                profileHeader
                menuCard
                favoritesCard
                logOutButton
            }
            .padding(.horizontal, Spacing.medium)
            .padding(.top, Spacing.medium)
            .padding(.bottom, 40)
        }
        .background(Color("AppBackground").ignoresSafeArea())
        .navigationTitle("Yaqeen")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color("TextPrimary"))
                        .frame(width: 36, height: 36)
                        .background(Color("CardBackground"))
                        .clipShape(Circle())
                        .appShadow(Shadow.subtle)
                }
            }
        }
    }

    // MARK: - Profile header (avatar + name + email)

    private var profileHeader: some View {
        VStack(spacing: Spacing.xs) {
            // Profile avatar — uses the same system icon as ProfileButton
            // but rendered larger, matching the screenshot's circular avatar.
            Image(systemName: "person.circle.fill")
                .font(.system(size: 100))
                .foregroundStyle(Color("TextPrimary"), Color(.systemGray5))
                .frame(width: 120, height: 120)
                .background(Color(.systemGray5))
                .clipShape(Circle())

            Text(userName)
                .font(.system(.title2, design: .rounded, weight: .bold))
                .foregroundStyle(Color("TextPrimary"))

            Text(userEmail)
                .font(Typography.bodySecondary)
                .foregroundStyle(Color("TextSecondary"))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, Spacing.medium)
    }

    // MARK: - Menu card (Informasi Personal + Points)

    private var menuCard: some View {
        VStack(spacing: 0) {
            // Informasi Personal row
            Button {
                // Clickable but doesn't navigate anywhere
            } label: {
                profileMenuRow(
                    icon: "person.fill",
                    iconBackground: Color(.systemGray4),
                    title: "Personal Information"
                )
            }
            .buttonStyle(.plain)

            Divider()
                .padding(.leading, 56)

            // Points row — switches to Points tab
            Button {
                onNavigateToPoints?()
            } label: {
                profileMenuRow(
                    icon: "gift.fill",
                    iconBackground: Color(red: 0.85, green: 0.68, blue: 0.20),
                    title: "Points"
                )
            }
            .buttonStyle(.plain)
        }
        .background(Color("CardBackground"))
        .clipShape(RoundedRectangle(cornerRadius: Radius.card))
        .appShadow(Shadow.card)
    }

    // MARK: - Favourites card

    private var favoritesCard: some View {
        VStack(spacing: 0) {
            // Header row with expand/collapse
            Button {
                withAnimation(.snappy) {
                    isFavoritesExpanded.toggle()
                }
            } label: {
                HStack(spacing: Spacing.small) {
                    Image(systemName: "bookmark.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(Color(red: 0.20, green: 0.60, blue: 0.30))
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                    Text("Favorite Restaurant")
                        .font(.system(.body, design: .default, weight: .semibold))
                        .foregroundStyle(Color("TextPrimary"))

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color("TextSecondary"))
                        .rotationEffect(.degrees(isFavoritesExpanded ? 90 : 0))
                }
                .padding(Spacing.cardPadding)
            }
            .buttonStyle(.plain)

            Divider()
                .padding(.horizontal, Spacing.cardPadding)

            // Scrollable restaurant grid inside the card
            ScrollView {
                VStack(spacing: Spacing.small) {
                    // Row 1: first 3 restaurants (always visible)
                    favoriteRow(restaurants: Array(favoriteRestaurants.prefix(3)))

                    // Expanded rows
                    if isFavoritesExpanded {
                        // Row 2: the 2 extra restaurants + 1 ghost placeholder
                        HStack(spacing: Spacing.small) {
                            ForEach(Array(favoriteRestaurants.dropFirst(3))) { restaurant in
                                Button {
                                    // Clickable but doesn't navigate
                                } label: {
                                    favoriteRestaurantCell(restaurant)
                                }
                                .buttonStyle(.plain)
                            }

                            // Ghost placeholder to fill the 3rd column
                            silhouetteCell()
                        }

                        // Row 3: full silhouette row — hints at more content
                        HStack(spacing: Spacing.small) {
                            silhouetteCell()
                            silhouetteCell()
                            silhouetteCell()
                        }
                        .opacity(0.45)
                    }
                }
                .padding(.horizontal, Spacing.cardPadding)
                .padding(.vertical, Spacing.small)
            }
            .frame(maxHeight: isFavoritesExpanded ? 420 : 155)
            .scrollIndicators(isFavoritesExpanded ? .automatic : .hidden)
        }
        .background(Color("CardBackground"))
        .clipShape(RoundedRectangle(cornerRadius: Radius.card))
        .appShadow(Shadow.card)
        .animation(.snappy, value: isFavoritesExpanded)
    }

    /// A row of favourite restaurant cells.
    private func favoriteRow(restaurants: [FavoriteRestaurant]) -> some View {
        HStack(spacing: Spacing.small) {
            ForEach(restaurants) { restaurant in
                Button {
                    // Clickable but doesn't navigate
                } label: {
                    favoriteRestaurantCell(restaurant)
                }
                .buttonStyle(.plain)
            }
        }
    }

    /// A single favourite restaurant cell.
    private func favoriteRestaurantCell(_ restaurant: FavoriteRestaurant) -> some View {
        VStack(spacing: Spacing.xs) {
            RoundedRectangle(cornerRadius: Radius.small)
                .fill(restaurant.iconColor)
                .frame(height: 90)
                .overlay {
                    Image(systemName: restaurant.systemIconFallback)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(restaurant.iconTextColor)
                }

            Text(restaurant.name)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color("TextPrimary"))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(minHeight: 32)
        }
        .frame(maxWidth: .infinity)
    }

    /// A ghost/silhouette placeholder cell that hints at more restaurants.
    private func silhouetteCell() -> some View {
        VStack(spacing: Spacing.xs) {
            RoundedRectangle(cornerRadius: Radius.small)
                .fill(Color(.systemGray5))
                .frame(height: 90)
                .overlay {
                    Image(systemName: "fork.knife")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(Color(.systemGray3))
                }

            RoundedRectangle(cornerRadius: 4)
                .fill(Color(.systemGray5))
                .frame(height: 10)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 8)
                .frame(minHeight: 32, alignment: .top)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Log Out button

    private var logOutButton: some View {
        Button {
            // Log out action placeholder
        } label: {
            Text("Log Out")
                .font(.system(.body, design: .default, weight: .semibold))
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.medium)
                .background(Color("CardBackground"))
                .clipShape(RoundedRectangle(cornerRadius: Radius.card))
                .appShadow(Shadow.card)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Reusable menu row

    private func profileMenuRow(icon: String, iconBackground: Color, title: String) -> some View {
        HStack(spacing: Spacing.small) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(iconBackground)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            Text(title)
                .font(.system(.body, design: .default, weight: .semibold))
                .foregroundStyle(Color("TextPrimary"))

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color("TextSecondary"))
        }
        .padding(Spacing.cardPadding)
    }
}

// MARK: - Favourite Restaurant model (local to profile)

/// Lightweight model for the favourite restaurants shown in the profile view.
/// Purely UI — not a domain model.
struct FavoriteRestaurant: Identifiable {
    let id = UUID()
    let name: String
    let iconName: String
    let iconColor: Color

    /// Fallback SF Symbol for when no bundled image exists yet.
    var systemIconFallback: String {
        switch iconName {
        case "pestaKebunIcon":   return "leaf.fill"
        case "allAceIcon":       return "flame.fill"
        case "subwayIcon":       return "arrow.triangle.2.circlepath"
        case "starbucksIcon":    return "cup.and.saucer.fill"
        case "marugameIcon":     return "bowl.fill"
        default:                 return "fork.knife"
        }
    }

    /// Text color on top of the icon background for contrast.
    var iconTextColor: Color {
        switch iconName {
        case "pestaKebunIcon":   return Color(red: 0.45, green: 0.35, blue: 0.15)
        case "allAceIcon":       return .red
        case "subwayIcon":       return .white
        case "starbucksIcon":    return .white
        case "marugameIcon":     return .white
        default:                 return .white
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ProfileView()
    }
}
