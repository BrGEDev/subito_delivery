//
//  Establishments.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 30/10/24.
//

import SwiftUI

struct PopularEstablishmentsResponse: Codable {
    let status: String
    let message: String
    let data: [PopularEstablishments]?
}

struct PopularEstablishments: Codable {
    let id_restaurant: String
    let name_restaurant: String
    let address: String
    let latitude: String
    let longitude: String
    let picture_logo: String?
    let picture_establishment: String?
}

struct GetEstablishmentsResponse: Codable{
    let status: String
    let message: String
    let data: [Establishments]?
}

struct Establishments: Codable {
    let id_restaurant: String
    let name_restaurant: String
    let address: String
    let latitude: String
    let longitude: String
    let picture_logo: String?
    let picture_establishment: String?
    let distance: Float?
}
