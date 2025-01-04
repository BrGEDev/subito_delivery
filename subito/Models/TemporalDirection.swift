//
//  TemporalDirection.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 02/01/25.
//

import Foundation
import MapKit

struct TemporalDirection: Identifiable, Codable {
    var id: UUID = .init()
    let full_address: String
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
}
