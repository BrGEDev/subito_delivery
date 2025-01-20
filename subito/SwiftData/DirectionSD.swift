//
//  DirectionSD.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 11/12/24.
//

import Foundation
import SwiftData

@Model
final class DirectionSD {
    @Attribute(.unique) var id: Int

    var name: String
    var full_address: String
    var reference: String
    var latitude: String
    var longitude: String
    var status: Bool
    
    init(id: Int, name: String = "", full_address: String, reference: String = "", latitude: String, longitude: String, status: Bool = false) {
        self.id = id
        self.name = name
        self.full_address = full_address
        self.reference = reference
        self.latitude = latitude
        self.longitude = longitude
        self.status = status
    }
}

