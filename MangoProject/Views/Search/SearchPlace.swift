import Foundation

struct SearchPlace: Identifiable {
    let id = UUID()
    let name: String
    let category: String
    let distanceText: String
    let rating: Double?
    let imageName: String?
}

extension SearchPlace {
    static let samples: [SearchPlace] = [
        SearchPlace(name: "Arabica The Breeze BSD City", category: "Cafe", distanceText: "0.1 m", rating: 4.2, imageName: nil),
        SearchPlace(name: "The Kluwih Heritage", category: "Indonesian", distanceText: "0.3 m", rating: 4.2, imageName: nil),
        SearchPlace(name: "Auntie Anne's", category: "Desserts", distanceText: "0.5 m", rating: 4.2, imageName: nil),
        SearchPlace(name: "Bakso Afung", category: "Indonesian", distanceText: "0.8 m", rating: 4.2, imageName: nil),
        SearchPlace(name: "Mujigae", category: "Indonesian", distanceText: "1.0 m", rating: 4.5, imageName: nil),
        SearchPlace(name: "Starbucks", category: "Cafe", distanceText: "1.2 m", rating: 4.0, imageName: nil),
        SearchPlace(name: "Nasi Goreng Mafia", category: "Indonesian", distanceText: "1.5 m", rating: 4.3, imageName: nil),
    ]
}
