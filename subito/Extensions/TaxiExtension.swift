//
//  TaxiExtension.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 29/11/24.
//

import SwiftUI
import MapKit

extension Taxi {
    func getDirections(location: CLLocation) {
        locationManager.geocode(location: location){ placemark, error in
            guard let placemark = placemark, error == nil else { return }
            
            fromAddress.searchText = "\(placemark.name ?? "") \(placemark.subLocality ?? "") \(placemark.locality ?? "") \(placemark.administrativeArea ?? "")"
            locatioN = "\(placemark.name ?? "") \(placemark.subLocality ?? "") \(placemark.locality ?? "") \(placemark.administrativeArea ?? "")"
            inicioViaje = "\(placemark.name ?? "") \(placemark.subLocality ?? "") \(placemark.locality ?? "") \(placemark.administrativeArea ?? "")"
        }
    }
    
    func geocode(address: AddressResult) {
        let searchRequest = MKLocalSearch.Request()
        let title = address.title
        let subTitle = address.subtitle
        
        searchRequest.naturalLanguageQuery = subTitle.contains(title)
        ? subTitle : title + ", " + subTitle

        let search = MKLocalSearch(request: searchRequest)
        
        search.start { response, error in
            guard let response = response else {
                print("Error: \(error?.localizedDescription ?? "Unknown error").")
                return
            }

            for item in response.mapItems {
                locate = item.name ?? ""
                coordinatess = item.placemark.coordinate
                fetchRoute(address: item)
            }
        }
    }
    
    
    func geocodeFrom(address: AddressResult, completion: @escaping (CLLocationCoordinate2D) -> Void) {
        let searchRequest = MKLocalSearch.Request()
        let title = address.title
        let subTitle = address.subtitle
        
        searchRequest.naturalLanguageQuery = subTitle.contains(title)
        ? subTitle : title + ", " + subTitle

        MKLocalSearch(request: searchRequest).start { response, error in
            guard let response = response else {
                print("Error: \(error?.localizedDescription ?? "Unknown error").")
                return
            }

            for item in response.mapItems {
                inicioViaje = item.placemark.name ?? ""
                completion(item.placemark.coordinate)
            }
        }
    }
    
    
    func fetchRoute(address: MKMapItem) {
        let request = MKDirections.Request()
        
        let destination = MKMapItem(placemark: MKPlacemark(coordinate: address.placemark.coordinate))
        
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: fromRoute!))
        request.destination = destination
        
        Task {
            let result = try? await MKDirections(request: request).calculate()
            route = result?.routes.first
            routeDestination = destination
            let km = ceil(Double(result?.routes.first?.distance ?? 0) / 1000)
            price = Int(km <= 6 ? 40 : ((km - 6) * 7) + 40)
            
            let timeExpect = result?.routes.first?.expectedTravelTime ?? 0
            let hours = Int(timeExpect) / 3600
            let minutes = (Int(timeExpect) / 60) % 60
            let calendar = Calendar.current
            var date = calendar.date(byAdding: .minute, value: minutes, to: Date.now)
            date = calendar.date(byAdding: .hour, value: hours, to: date!)
            
            estimatedTime = date!.formatted(date: .omitted, time: .shortened)
            
            withAnimation(.snappy){
                routeDisplay = true
                
                if let rect = route?.polyline.boundingMapRect, routeDisplay {
                    coords = .rect(rect)
                }
            }
        }
        
    }
    
    func loadUser() {
        if let data = UserDefaults.standard.object(forKey: "user_logged") as? Data,
           let user = try? JSONDecoder().decode(LoginData.self, from: data){
            userData = user.user
        }
    }
}
