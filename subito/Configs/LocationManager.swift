import Foundation
import MapKit

class LocationManager: NSObject, ObservableObject, MKMapViewDelegate, CLLocationManagerDelegate{
    @Published var manager: CLLocationManager = .init()
    @Published var userLocation: CLLocationCoordinate2D = .init(latitude: 19.0414398, longitude: -98.2062727)
    @Published var coordinates: CLLocation = .init(latitude: 19.0414398, longitude: -98.2062727)
    @Published var printPosition: [String: String] = [:]
    @Published var isLocationAuthorized: Bool = false
    
    override init() {
        super.init()
        
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.allowsBackgroundLocationUpdates = true
        manager.pausesLocationUpdatesAutomatically = false
    }
    
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { await checkAuthorization() }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else {return}
        
        printPosition = [
            "lat" : String(currentLocation.coordinate.latitude),
            "lng" : String(currentLocation.coordinate.longitude)
        ]
        
        userLocation = .init(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        coordinates = .init(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        isLocationAuthorized = true
    }
    
    func geocode(location: CLLocation, completion: @escaping (CLPlacemark?, Error?) -> ()){
        CLGeocoder().reverseGeocodeLocation(location) {
            completion($0?.first, $1)
        }
    }
        
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        checkAuthorization()
    }
    
    func checkAuthorization() {
        switch manager.authorizationStatus{
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .denied:
            manager.requestWhenInUseAuthorization()
        case .authorizedAlways,.authorizedWhenInUse:
            manager.requestLocation()
        default:
            break
        }
    }
}
