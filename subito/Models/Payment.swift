//
//  Untitled.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 17/12/24.
//

import Foundation
import SwiftUI

//Obtener métodos de pago

struct PaymentMethodResponse: Decodable {
    var status: String
    var message: String
    var data: [PaymentMethods]?
    
    struct PaymentMethods: Decodable{
        var id: String
        var customer_id: String
        var expiration_month: Int
        var expiration_year: Int
        var first_six_digits: String
        var last_four_digits: String
        var payment_method: InfoPaymentMethod
        var security_code: SecurityCode
        var issuer: Issuer
        var cardholder: CardHolder
        var date_created: String
        var date_last_updated: String
        var user_id: String
        var live_mode: Bool
        
        struct InfoPaymentMethod: Decodable{
            var id: String
            var name: String
            var payment_type_id: String
            var thumbnail: String
            var secure_thumbnail: String
        }

        struct SecurityCode: Decodable{
            var length: Int
            var card_location: String
        }

        struct Issuer: Decodable {
            var id: Int?
            var name: String?
        }

        struct CardHolder: Decodable {
            var name: String?
            var identification: IdentificationHolder?
            
            struct IdentificationHolder: Decodable{
                var type: String?
                var number: String?
            }
        }
    }
}


struct PaymentsResponse: Decodable {
    var status: String
    var message: String
}

struct CheckoutResponse: Decodable {
    var status: String?
    var message: String
    var data: CheckoutData?
}

struct CheckoutData: Decodable {
    var responseMP: ResponseMP?
    var orderId: Int
    var establishmentId: Int
}

struct ResponseMP: Decodable {
    var status: String
    var status_detail: String
}
