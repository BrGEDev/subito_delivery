//
//  Shopping.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 13/12/24.
//

struct ShoppingResponse: Decodable {
    var status: String
    var message: String
    var shopping: Shopping?
    
    struct Shopping: Decodable {
        var establishment_id: String
        var order: Order
        
        struct Order: Decodable {
            var products: [Products]
        
            struct Products: Decodable {
                var pd_id: String
                var pd_name: String
                var pd_unit_price: String
                var pd_quantity: String
                var pd_image: String
                var name_restaurant: String
                var picture_logo: String
                var latitude: String
                var longitude: String
            }
        }
    }
}


