//
//  UserSD.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 11/12/24.
//

import SwiftData
import Foundation

@Model
class UserSD {
    @Attribute(.unique) var id: Int
    
    var name: String
    var lastName: String
    var email: String
    var birthday: String?
    var phone: String?
    var token: String
    
    init(id: Int, name: String, lastName: String, email: String, phone: String? = "", birthday: String? = "", token: String) {
        self.id = id
        self.name = name
        self.lastName = lastName
        self.email = email
        self.phone = phone
        self.birthday = birthday
        self.token = token
    }
}

@Model
class CartSD {
    @Attribute(.unique)
    var id: Int
    
    var establishment: String
    var latitude: String
    var longitude: String
    
    @Relationship(deleteRule: .cascade)
    var products: [ProductsSD]
    
    init (id: Int, establishment: String, latitude: String = "", longitude: String = "") {
        self.id = id
        self.establishment = establishment
        self.latitude = latitude
        self.longitude = longitude
        self.products = [ProductsSD]()
    }
}

@Model
class ProductsSD {
    @Attribute(.unique) var id: Int
    
    var product: String
    var image: String
    var descript: String
    var unit_price: Float
    var amount: Int
    var establishment: CartSD?
    
    init(id: Int, product: String, image: String, descript: String, unit_price: Float, amount: Int, establishment: CartSD? = nil) {
        self.id = id
        self.product = product
        self.image = image
        self.descript = descript
        self.unit_price = unit_price
        self.amount = amount
        self.establishment = establishment
    }
}
