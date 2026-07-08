import Foundation
import MapKit
import Combine

@MainActor
class RestaurantDetailViewModel: ObservableObject {
    let place: NearbyFoodPlace
    
    @Published var resolvedAddress: String = ""
    @Published var resolvedPhone: String?
    @Published var resolvedURL: URL?
    @Published var isLoadingDetails: Bool = true
    
    init(place: NearbyFoodPlace) {
        self.place = place
    }
    
    func loadDetails() {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let placemark = placemarks?.first {
                let addressParts = [
                    placemark.thoroughfare,
                    placemark.subThoroughfare,
                    placemark.locality,
                    placemark.subAdministrativeArea,
                    placemark.administrativeArea,
                    placemark.postalCode,
                    placemark.country
                ]
                .compactMap { $0 }
                .filter { !$0.isEmpty }
                
                let address = addressParts.joined(separator: ", ")
                DispatchQueue.main.async {
                    self.resolvedAddress = address.isEmpty ? "The Breeze, BSD City, Tangerang" : address
                }
            }
        }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = place.name
        request.region = MKCoordinateRegion(
            center: place.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
        )
        
        MKLocalSearch(request: request).start { response, error in
            if let response = response, let mapItem = response.mapItems.first {
                DispatchQueue.main.async {
                    if let phone = mapItem.phoneNumber {
                        self.resolvedPhone = phone
                    }
                    if let url = mapItem.url {
                        self.resolvedURL = url
                    }
                    self.isLoadingDetails = false
                }
            } else {
                DispatchQueue.main.async {
                    self.isLoadingDetails = false
                }
            }
        }
    }
}
