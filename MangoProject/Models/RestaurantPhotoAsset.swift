//
//  RestaurantPhotoAsset.swift
//  MangoProject
//

import UIKit

/// Maps a verified halal restaurant's display name to its asset catalog
/// image names. Each restaurant gets `photosPerRestaurant` empty `.imageset`
/// slots (named `<base>_1` ... `<base>_5`) in Assets-Photos.xcassets, ready
/// for real photos to be dropped in — restaurants not yet photographed
/// simply have no images assigned, and `RestaurantPhotoView`/gallery views
/// fall back to a category placeholder.
enum RestaurantPhotoAsset {
    static let photosPerRestaurant = 5

    private static let baseNames: [String: String] = [
        // Maggiore
        "Kopi Kenangan": "restaurant_kopi_kenangan",
        "Mie Bandung Kejaksaan 1964": "restaurant_mie_bandung_kejaksaan_1964",
        "Luuca": "restaurant_luuca",
        "Su Wah": "restaurant_su_wah",
        "Ottimo": "restaurant_ottimo",
        "My Coco": "restaurant_my_coco",
        "Milled Artisan Bakery": "restaurant_milled_artisan_bakery",
        "Nasi Bakar Noni": "restaurant_nasi_bakar_noni",
        "Teman Nongkrong": "restaurant_teman_nongkrong",
        "Kwetiau Laopan": "restaurant_kwetiau_laopan",
        "Sinar Medan": "restaurant_sinar_medan",
        "The Sanctuary": "restaurant_the_sanctuary",
        "Home Made Bakery": "restaurant_home_made_bakery",

        // The Breeze
        "Bebek Bengil": "restaurant_bebek_bengil",
        "BOOST": "restaurant_boost",
        "CHAGEE": "restaurant_chagee",
        "Chatime": "restaurant_chatime",
        "Dore": "restaurant_dore",
        "Fore": "restaurant_fore",
        "Fruity": "restaurant_fruity",
        "GION": "restaurant_gion",
        "Hachi Grill": "restaurant_hachi_grill",
        "HAN GUKSU": "restaurant_han_guksu",
        "HONU": "restaurant_honu",
        "J.CO": "restaurant_j_co",
        "Jalarasa": "restaurant_jalarasa",
        "Kitchenette": "restaurant_kitchenette",
        "Leko": "restaurant_leko",
        "Re.juve": "restaurant_re_juve",
        "SALADSTOP": "restaurant_saladstop",
        "Shihlin": "restaurant_shihlin",
        "Sour Sally": "restaurant_sour_sally",
        "Starbucks": "restaurant_starbucks",
        "SUBWAY": "restaurant_subway",
        "SUSHI TEI": "restaurant_sushi_tei",
        "TAMPER": "restaurant_tamper",
        "Toby's Estate": "restaurant_tobys_estate",
        "Wee Nam Kee": "restaurant_wee_nam_kee",
    ]

    /// All possible asset names for this restaurant's photo slots, in
    /// order. Not every name is guaranteed to have a real image assigned —
    /// callers should check each one (e.g. via `UIImage(named:)`) and
    /// treat missing ones as empty.
    static func assetNames(for restaurantName: String) -> [String] {
        guard let base = baseNames[restaurantName] else { return [] }
        return (1...photosPerRestaurant).map { "\(base)_\($0)" }
    }

    /// Only the slots that actually have a real photo assigned, in order.
    /// Empty for a restaurant with no photos uploaded yet.
    static func availableImages(for restaurantName: String) -> [UIImage] {
        assetNames(for: restaurantName).compactMap { UIImage(named: $0) }
    }

    static func categoryIcon(for category: String) -> String {
        switch category.lowercased() {
        case "cafe":
            "cup.and.saucer.fill"
        case "beverages":
            "takeoutbag.and.cup.and.straw.fill"
        case "dessert", "bakery":
            "birthday.cake.fill"
        case "healthy":
            "leaf.fill"
        default:
            "fork.knife"
        }
    }
}
