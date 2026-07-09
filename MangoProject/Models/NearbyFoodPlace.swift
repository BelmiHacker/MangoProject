//
//  NearbyFoodPlace.swift
//  MangoProject
//
//  Created by Belmiro Kayru on 05/07/26.
//

import CoreLocation
import Foundation
import MapKit

struct NearbyFoodPlace: Identifiable, Hashable {
    let id: String
    let name: String
    let address: String
    let category: String
    let coordinate: CLLocationCoordinate2D
    let phoneNumber: String?
    let url: URL?
    let distanceInMeters: CLLocationDistance?
    let mapItem: MKMapItem
    let businessName: String?
    let certificateNumber: String?
    let certificateIssueDate: String?
    let totalProducts: Int?
    let isHalal: Bool

    var distanceText: String {
        guard let distanceInMeters else {
            return "Distance unavailable"
        }

        if distanceInMeters >= 1_000 {
            return String(format: "%.1f km", distanceInMeters / 1_000)
        }

        return "\(Int(distanceInMeters.rounded())) m"
    }

    var addressLines: [String] {
        address
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    static func == (lhs: NearbyFoodPlace, rhs: NearbyFoodPlace) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension NearbyFoodPlace {
    init(mapItem: MKMapItem, userLocation: CLLocation?, csvPlace: CSVPlace? = nil) {
        let coordinate: CLLocationCoordinate2D
        let addressParts: [String]

        if #available(iOS 26, *) {
            coordinate = mapItem.location.coordinate
            let fullAddr = mapItem.addressRepresentations?.fullAddress(includingRegion: true, singleLine: true)
                ?? mapItem.address?.fullAddress
                ?? ""
            addressParts = fullAddr.isEmpty ? [] : [fullAddr]
        } else {
            let placemark = mapItem.placemark
            coordinate = placemark.coordinate
            addressParts = [
                placemark.thoroughfare,
                placemark.subThoroughfare,
                placemark.locality,
                placemark.administrativeArea,
                placemark.country
            ]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
        }

        let placeLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let distance = userLocation?.distance(from: placeLocation)

        self.id = [
            mapItem.name ?? "Unknown",
            String(format: "%.6f", coordinate.latitude),
            String(format: "%.6f", coordinate.longitude)
        ].joined(separator: "-")
        self.name = mapItem.name ?? "Unnamed place"
        self.address = addressParts.joined(separator: ", ")
        if let csvType = csvPlace?.type, !csvType.isEmpty {
            self.category = csvType
        } else {
            self.category = mapItem.pointOfInterestCategory?.displayName ?? "Food place"
        }
        self.coordinate = coordinate
        self.phoneNumber = mapItem.phoneNumber
        self.url = mapItem.url
        self.distanceInMeters = distance
        self.mapItem = mapItem
        self.businessName = csvPlace?.businessName
        self.certificateNumber = csvPlace?.certificateNumber
        self.certificateIssueDate = csvPlace?.certificateIssueDate
        self.totalProducts = csvPlace?.totalProducts
        self.isHalal = csvPlace?.halalFound ?? false
    }
}

private extension MKPointOfInterestCategory {
    var displayName: String {
        switch self {
        case .bakery:
            return "Bakery"
        case .cafe:
            return "Cafe"
        case .restaurant:
            return "Restaurant"
        default:
            return "Food Place"
        }
    }
}
