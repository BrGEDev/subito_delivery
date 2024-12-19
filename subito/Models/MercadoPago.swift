//
//  MercadoPago.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 17/12/24.
//

struct CardTokens:Decodable {
    var id: String
    var public_key: String
    var card_id: String
    var status: String
    var date_created: String
    var date_last_updated: String
    var date_due: String
    var luhn_validation: Bool
    var live_mode: Bool
    var require_esc: Bool
    var security_code_length: Int
}
