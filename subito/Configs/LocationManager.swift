import CoreLocation

class LocationManager: NSObject, ObservableObject {
    private let manager = CLLocationManager()
    @Published var userLocation: CLLocation?
    @Published var coords: CLLocationCoordinate2D?
    static let shared = LocationManager()
    
    override init() {
        super.init()
        
        manager.delegate = self
        manager.requestAlwaysAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocation() {
        manager.requestLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manafer: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
            
            case .notDetermined:
                print("Not Determined")
                manager.requestAlwaysAuthorization()
            case .restricted:
                print("Restricted")
                manager.requestAlwaysAuthorization()
            case .denied:
                print("Denied")
                manager.requestAlwaysAuthorization()
            case .authorizedAlways, .authorizedWhenInUse:
                print("Start Updating Location")
           
            @unknown default:
                print("IDK")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location
        coords = location.coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print(error)
    }
    
    func geocode(location: CLLocationCoordinate2D?, completion: @escaping (CLPlacemark?, Error?) -> ()){
        guard location != nil else {
            completion(nil, nil)
            return
        }
        
        let locate: CLLocation = .init(latitude: location!.latitude, longitude: location!.longitude)
        CLGeocoder().reverseGeocodeLocation(locate) {
            completion($0?.first, $1)
        }
    }
}
