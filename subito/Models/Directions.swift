//
//  Directions.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 11/12/24.
//


struct DirectionsResponse: Decodable {
    let status: String
    let message: String
    let data: [DirectionsData]?
}

struct DirectionsData: Decodable {
    let ad_id: Int
    let ad_latitude: String
    let ad_longitude: String
    let ad_full_address: String
    let ad_user_id: String
}

struct SaveDirectionsResponse: Decodable {
    let status: String
    let message: String
}
