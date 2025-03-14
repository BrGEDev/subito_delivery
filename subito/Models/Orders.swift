//
//  Orders.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 19/12/24.
//

import Foundation
import SwiftUI

struct OrdersResponse: Decodable {
    let status: String
    let message: String
    let data: [Orders]?
}

struct Orders: Decodable {
    let id_order: String
    let no_order: String
    let time_order: String
    let name_restaurant: String
    let address: String
    let picture_logo: String
    let created_at: String
    let payment: String
    let status: String
}



struct DetailOrderResponse: Decodable {
    let status: String
    let message: String
    let data: OrderDetails?
}

struct OrderDetails: Decodable {
    var order: OrderDetailModel?
    var products: [ProductsDetailModel]?
}

struct OrderDetailModel: Decodable {
    var id_order: String
    var time_order: String
    var no_order: String
    var total: String
    var ad_full_address: String
    var id_delivery: String?
    var name: String?
    var last_name: String?
    var delivery_phone: String?
    var id_status: String
    var status: String
    var name_restaurant: String
    var establishment_phone: String
    var costo_envio: String
    var picture_logo: String
    var created_at: String
    var client_latitude: String
    var client_longitude: String
    var establishment_latitude: String
    var establishment_longitude: String
    var picture_order: String?
}

struct ProductsDetailModel: Decodable {
    var pd_name: String
    var pd_image: String
    var pd_unit_price: String
    var sp_quantity: String
}


struct LocationResponse: Decodable {
    var status: String
    let message: String
    let data: LocationModel?
}

struct LocationModel: Decodable {
    let id_delivery: String
    let latitude: String
    let longitude: String
}

struct HistoryResponse: Decodable {
    let status: String
    let message: String
    let data: [HistoryData]?
}

struct HistoryData: Decodable {
    let id_order: String
    let no_order: String
    let time_order: String
    let name_restaurant: String
    let address: String
    let picture_logo: String
    let created_at: String
    let payment: String
    let status: String
    let client_latitude: String
    let client_longitude: String
    let establishment_longitude: String
    let establishment_latitude: String
}
