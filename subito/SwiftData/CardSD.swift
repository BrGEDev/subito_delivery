//
//  CardSD.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 16/12/24.
//

import SwiftData
import Foundation

@Model
final class CardSD {
    @Attribute(.unique) var id: String
    
    var last_four: String
    var card_type: String
    var expiry: String
    var brand: String
    var name: String
    var status: Bool
    var token: String?
    
    init(id: String, last_four: String, card_type: String, expiry: String, brand: String, name: String, status: Bool = false, token: String?) {
        self.id = id
        self.last_four = last_four
        self.card_type = card_type
        self.expiry = expiry
        self.brand = brand
        self.name = name
        self.status = status
        self.token = token
    }
}
