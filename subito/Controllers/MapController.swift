//
//  MapController.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 01/10/24.
//

import MapKit

extension CLLocationCoordinate2D {
    static var Puebla: CLLocationCoordinate2D {
        return .init(latitude: 19.0414398, longitude: -98.2062727)
    }
}

extension MKCoordinateRegion {
    static var userRegion: MKCoordinateRegion {
        return .init(center: .Puebla, latitudinalMeters: 500, longitudinalMeters: 500)
    }
}
