//
//  TrackingSD.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 19/12/24.
//

import Foundation
import SwiftData

@Model
class TrackingSD {
    @Attribute(.unique)
    var id: UUID
    
    @Relationship(deleteRule: .cascade)
    var establishment = [TrackingEstablishmentSD]()
    @Relationship(deleteRule: .cascade)
    var client = [TrackingClientSD]()
    
    var time_stimated: Date
    
    init(id: UUID, time_stimated: Date) {
        self.id = id
        self.time_stimated = time_stimated
    }
}

@Model
class TrackingEstablishmentSD {
    @Attribute(.unique)
    var id: Int
    
    var name: String
    var address: String
    var latitude: Double
    var longitude: Double
    var tracking: TrackingSD?
    
    init(id: Int, name: String, address: String, latitude: Double, longitude: Double, tracking: TrackingSD? = nil) {
        self.id = id
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.tracking = tracking
    }
}

@Model
class TrackingClientSD {
    @Attribute(.unique)
    var id: Int
    
    var name: String
    var address: String
    var latitude: Double
    var longitude: Double
    var tracking: TrackingSD?
    
    init(id: Int, name: String, address: String, latitude: Double, longitude: Double, tracking: TrackingSD? = nil) {
        self.id = id
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.tracking = tracking
    }
}
