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
    
    var order: Int
    var establishment: String
    var estimatedTime: String
    
    init(id: UUID = UUID(), order: Int, establishment: String, estimatedTime: String) {
        self.id = id
        self.order = order
        self.establishment = establishment
        self.estimatedTime = estimatedTime
    }
}
