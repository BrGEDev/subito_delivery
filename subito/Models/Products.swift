//
//  Products.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 13/11/24.
//

import SwiftUI

struct ProductsResponse: Decodable{
    var status: String
    var message: String
    var data: [Product]?
}

struct Product: Decodable {
    var pg_id: Int
    var pg_name: String
    //var pg_description: String
    var pg_establishments_id: String
    var name_restaurant: String
    //var created_at: String?
    //var updated_at: String?
    var ps_id: String
    var ps_name: String
    //var ps_description: String
    var ps_products_categories_id: String
    var pd_id: String
    var pd_name: String
    var pd_description: String?
    var pd_image: String?
    var pd_unit_price: String
    var pd_product_subcategories_id: String?
    var pd_quantity: String?
    //var pd_serial_number: String?
    //var pd_brand: String?
    //var pd_net_content: String?
    var pd_disabled: String?
    var pd_delivery_time: String?
    var apertura: String?
    var cierre: String?
    var latitude: String?
    var longitude: String?
}
