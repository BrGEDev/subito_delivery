//
//  PrePurchase.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 26/02/25.
//

struct PrePurchaseResponse: Decodable {
    let status: String
    let message: String
    let data: PrePurchaseData?
}

struct PrePurchaseData: Decodable {
    let establishment: EstablishmentPrePurchase
    let km_base: String
    let price_base_km: String
    let price_km_extra: String
}

struct EstablishmentPrePurchase: Decodable {
    let id_restaurant: String
    let percent: String
    let monto_envio_gratis: String?
}
