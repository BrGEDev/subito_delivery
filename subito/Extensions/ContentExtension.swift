//
//  ContentExtension.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 26/11/24.
//

import SwiftUI
import SwiftData
import MapKit

extension ContentView {
    func getDirections(location: CLLocation) {
        locationManager.geocode(location: location){ placemark, error in
            guard let placemark = placemark, error == nil else { return }
            
            let full_address = "\(placemark.name ?? "") \(placemark.subLocality ?? "") \(placemark.locality ?? "") \(placemark.administrativeArea ?? "")"
            
            var descriptor: FetchDescriptor<DirectionSD>{
                return FetchDescriptor<DirectionSD>(predicate: #Predicate{$0.status == true })
            }
        
            let query = try! modelContext.fetch(descriptor).last
            
            let descriptor2 : FetchDescriptor<DirectionSD> = FetchDescriptor<DirectionSD>(predicate: #Predicate{$0.id == 0})
            let existLocation = try! modelContext.fetch(descriptor2).first
            
            if existLocation == nil {
                let livelocation = DirectionSD(id: 0, full_address: full_address, latitude: String(placemark.location!.coordinate.latitude), longitude: String(placemark.location!.coordinate.longitude), status: query == nil ? true : false)
                modelContext.insert(livelocation)
            } else {
                existLocation?.full_address = full_address
            }
            try! modelContext.save()
        }
    }
}
