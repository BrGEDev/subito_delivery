//
//  DirectionsModalExtension.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 11/12/24.
//

import MapKit
import SwiftData
import SwiftUI


enum DirectionsOptions {
    case addDirection(address: AddressResult)
    case editDirection(address: DirectionSD)
}

extension DirectionsModal {

    func getDirections(location: CLLocation) {
        locationManager.geocode(location: location) { placemark, error in
            guard let placemark = placemark, error == nil else { return }

            let full_address =
                "\(placemark.name ?? "") \(placemark.subLocality ?? "") \(placemark.locality ?? "") \(placemark.administrativeArea ?? "")"
            let existLocation = directions.first(where: { $0.id == 0 })
            if existLocation == nil {
                let livelocation = DirectionSD(
                    id: 0, full_address: full_address,
                    latitude: String(placemark.location!.coordinate.latitude),
                    longitude: String(placemark.location!.coordinate.longitude)
                )
                context.insert(livelocation)
            } else {
                existLocation?.full_address = full_address
                existLocation?.latitude = String(placemark.location!.coordinate.latitude)
                existLocation?.longitude = String(placemark.location!.coordinate.longitude)
            }
            try! context.save()
        }
    }

    func loadDirections(string: String? = nil) {
        let query = FetchDescriptor<UserSD>()
        let token = try? context.fetch(query).first?.token

        if token != nil {
            api.fetch(
                url: "address/get", method: "GET", token: token!,
                ofType: DirectionsResponse.self
            ) { res in
                if res.status == "success" {
                    for address in res.data! {
                        let direction =
                            DirectionSD(
                                id: address.ad_id,
                                name: address.ad_name ?? "",
                                full_address: address.ad_full_address,
                                reference: address.ad_reference ?? "",
                                latitude: address.ad_latitude,
                                longitude: address.ad_longitude)

                        if directions.count == 0 {
                            context.insert(direction)
                        } else {
                            let id: Int = address.ad_id
                            let directionToUpdate = directions.first(where: {
                                $0.id == id
                            })
                            if directionToUpdate != nil {
                                directionToUpdate!.full_address =
                                    address.ad_full_address
                                directionToUpdate!.latitude =
                                    address.ad_latitude
                                directionToUpdate!.longitude =
                                    address.ad_longitude
                                directionToUpdate!.name = address.ad_name ?? ""
                                directionToUpdate!.reference = address.ad_reference ?? ""
                            } else {
                                context.insert(direction)
                            }
                        }

                        do {
                            try context.save()
                            if string != nil{
                                updateSelected(string: string)
                            }
                        } catch {
                            fatalError("Error saving directions: \(error)")
                        }
                    }
                }
            }
        }
    }

    func deleteDirection(offsets: IndexSet) {
        let query = FetchDescriptor<UserSD>()
        let token = try? context.fetch(query).first?.token

        for index in offsets {
            let address = directions[index]
            
            api.fetch(url: "address/delete", method: "POST", body:["id_address": address.id], token: token!, ofType: SaveDirectionsResponse.self) {res in }
            
            context.delete(address)
            try! context.save()
        }
    }
    
    func drop(address: DirectionSD) {
        let query = FetchDescriptor<UserSD>()
        let token = try? context.fetch(query).first?.token
        
        api.fetch(url: "address/delete", method: "POST", body:["id_address": address.id], token: token!, ofType: SaveDirectionsResponse.self) {res in
            if res.status == "success" {
                context.delete(address)
                try! context.save()
            }
        }
    }

    func updateSelected(address: DirectionSD? = nil, string: String? = nil) {
        for direction in directions {
            direction.status = false
        }
        
        if string == nil && address != nil {
            address!.status = true
        } else {
            let query = FetchDescriptor<DirectionSD>(predicate: #Predicate{
                $0.full_address == string!
            })
            let add = try! context.fetch(query).first
            add?.status = true
        }
        
        try! context.save()
        dismiss()
    }
}
