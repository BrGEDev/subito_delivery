//
//  DirectionsModalExtension.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 11/12/24.
//

import MapKit
import SwiftData
import SwiftUI

extension DirectionsModal {

    func getDirections(location: CLLocation) {
        locationManager.geocode(location: location) { placemark, error in
            guard let placemark = placemark, error == nil else { return }

            let full_address =
                "\(placemark.name ?? "") \(placemark.subLocality ?? "") \(placemark.locality ?? "") \(placemark.administrativeArea ?? "")"
            let query = directions.last(where: { $0.status == true })
            let existLocation = directions.first(where: { $0.id == 0 })
            if existLocation == nil {
                let livelocation = DirectionSD(
                    id: 0, full_address: full_address,
                    latitude: String(placemark.location!.coordinate.latitude),
                    longitude: String(placemark.location!.coordinate.longitude),
                    status: query == nil ? true : false
                )
                context.insert(livelocation)
            } else {
                existLocation?.full_address = full_address
            }
            try! context.save()
        }
    }

    func loadDirections() {
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
                                full_address: address.ad_full_address,
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
                            } else {
                                context.insert(direction)
                            }
                        }

                        do {
                            try context.save()
                        } catch {
                            fatalError("Error saving directions: \(error)")
                        }
                    }
                }
            }
        }
    }

    func createDirection(address: AddressResult) {
        geocodeDirection(address: address) { res in
            let data = [
                "full_address": "\(address.title) \(address.subtitle)",
                "latitude": res.latitude,
                "longitude": res.longitude,
            ]

            api.fetch(
                url: "address/add", method: "POST", body: data, token: "",
                ofType: SaveDirectionsResponse.self
            ) { response in
                if response.status == "success" {
                    //let newDirection = DirectionSD(id: <#T##Int#>, full_address: String, latitude: <#T##String#>, longitude: <#T##String#>)
                    //modelContext.insert(Dore)
                    //dismiss()
                }
            }
        }
    }

    func deleteDirection(offsets: IndexSet) {
        let query = FetchDescriptor<UserSD>()
        let token = try? context.fetch(query).first?.token

        for index in offsets {
            let address = directions[index]
            
            api.fetch(url: "address/delete", method: "POST", body:["id_address": address.id], token: token!, ofType: SaveDirectionsResponse.self) {res in
                if res.status == "success" {
                    context.delete(address)
                    try! context.save()
                }
            }
        }
    }

    func geocodeDirection(
        address: AddressResult,
        completion: @escaping (CLLocationCoordinate2D) -> Void
    ) {
        let searchRequest = MKLocalSearch.Request()
        let title = address.title
        let subTitle = address.subtitle

        searchRequest.naturalLanguageQuery =
            subTitle.contains(title)
            ? subTitle : title + ", " + subTitle

        MKLocalSearch(request: searchRequest).start { response, error in
            guard let response = response else {
                print(
                    "Error: \(error?.localizedDescription ?? "Unknown error").")
                return
            }

            for item in response.mapItems {
                completion(item.placemark.coordinate)
            }
        }
    }

    func updateSelected(address: DirectionSD) {
        for direction in directions {
            direction.status = false
        }
        address.status = true
        try! context.save()
        dismiss()
    }
}
