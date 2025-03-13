//
//  Shopping.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 13/12/24.
//

struct ShoppingResponse: Decodable {
    var status: String
    var message: String
    var data: Shopping?
}

struct Shopping: Decodable {
    var establishment_id: String
    var establishment_latitude: String
    var establishment_longitude: String
    var order: Order
}

struct Order: Decodable {
    var products: [Products]
}

struct Products: Decodable {
    var pd_id: String
    var pd_name: String
    var pd_unit_price: String
    var pd_quantity: String
    var pd_image: String
    var name_restaurant: String
    var picture_logo: String
}

struct ShoppingModResponse: Decodable{
    var status: String
    var message: String
}
