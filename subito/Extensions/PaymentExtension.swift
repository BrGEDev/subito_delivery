//
//  PaymentExtension.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 25/11/24.
//

import SwiftData
import SwiftUI
import MapKit
import Foundation

extension Double {
    func decimals(_ fractionDigits: Int) -> Double {
        let multiplier = pow(10.0, Double(fractionDigits))
        return Darwin.round(self * multiplier) / multiplier
    }
}

extension PaymentModal {
    func loadPayment() {
        var sum: Float = 0
        
        for est in establishments {
            for product in est.products {
                sum += Float(product.amount) * product.unit_price
            }
            subtotal = sum
        }
    }
    
    func loadTaxes() {
        if segment == -1 {
            modalPropina = true
            return
        } else {
            propina = segment
            calcTax()
        }
    }
    
    func calcTax() {
        let presubtotal = subtotal + envio
        prepropina =  presubtotal * (Float(propina) / 100)
        payment = prepropina + presubtotal
    }
    
    func buyCart() {
        guard paymentsSelected!.token != nil else {
            cvvCode = true
            return
        }
        
        var products: Array<[String: Any]> = []
        var i = 0
        while establishments[0].products.count > i {
            products.append([
                "id": establishments[0].products[i].id,
                "quantity": establishments[0].products[i].amount
            ])
            
            i += 1
        }
        
        let data: [String: Any] = [
            "establishment_id": establishments[0].id,
            "payment": [
                "type": 3,
                "card_token": paymentsSelected!.token!,
                "payment_method_id": paymentsSelected!.token!
            ],
            "delivery": [
                "address": [
                    "id": directionSelected!.id
                ]
            ],
            "order": [
                "products": products,
                "total": payment,
                "shipping_cost": envio,
                "distance_km": km
            ]
        ]
        
        print(data)
        
        let user = FetchDescriptor<UserSD>()
        let userQuery = try! self.context.fetch(user).first!.token
        api.fetch(url: "payment", method: "POST", body: data, token: userQuery, ofType: PaymentsResponse.self) { res in
            print(res)
        }

//        do {
//            currentDeliveryState = .pending
//            activityIdentifier = try DeliveryActivity.startActivity(
//                deliveryStatus: .inProgress, establishment: establishments[0].establishment,
//                estimaed: "11:30 am", time: "8 min")
//            
//            
//            isPresented.toggle()
//        } catch {
//            print(error.localizedDescription)
//        }
    }

    // Actualiza el status del widget

    func updateState() {
        currentDeliveryState = .inProgress

        Task {
            await DeliveryActivity.updateActivity(
                activityIdentifier: activityIdentifier,
                newStatus: currentDeliveryState,
                establishment: "Starbucks Coffee", estimated: "11:30 am",
                time: "8 min")
        }
    }

    // Remueve el status del widget

    func removeState() {
        Task {
            await DeliveryActivity.endActivity(
                withActivityIdentifier: activityIdentifier)
        }
    }
    
    func calcDistance() {
        if directionSelected != nil && establishments[0].latitude != "" {
            let request = MKDirections.Request()
            
            let destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: Double(establishments[0].latitude) ?? 0, longitude: Double(establishments[0].longitude) ?? 0)))
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: Double(directionSelected!.latitude)!, longitude: Double(directionSelected!.longitude)!)))
            request.destination = destination
            
            Task {
                let result = try? await MKDirections(request: request).calculate()
                km = ceil(Double(result?.routes.first?.distance ?? 0) / 1000).decimals(2)
                envio = Float(km <= 6 ? 40 : ((km - 6) * 7) + 40)
                calcTax()
            }
        } else {
            envio = 40
            calcTax()
        }
    }
}

extension PaymentMethod {
    func getPaymentMethod() {
        api.fetch(
            url: "payment-methods", method: "POST", token: user!.token,
            ofType: PaymentMethodResponse.self
        ) { res in
            if res.data?.count != 0 {
                for card in res.data! {
                    let query = cards.first(where: { $0.id == card.id })
                    
                    if query == nil {
                        let newCard = CardSD(
                            id: card.id, last_four: card.last_four_digits,
                            card_type: card.payment_method.name == "master"
                            || card.payment_method.name == "debmaster"
                            ? "MasterCard"
                            : (card.payment_method.name == "visa"
                               || card.payment_method.name == "debvisa"
                               ? "Visa" : "American Express"),
                            expiry:
                                "\(card.expiration_month)/\(card.expiration_year)",
                            brand: card.payment_method.secure_thumbnail,
                            name: card.cardholder.name,
                            token: nil)
                        
                        contextModel.insert(newCard)
                    }
                }
                
                try! contextModel.save()
            }
        }
    }

    func deleteCard(offsets: IndexSet) {
        for index in offsets {
            let card = cards[index]
            
            api.fetch(url: "payment-methods/delete", method: "POST", body: ["payment_method_id": card.id], token: user!.token, ofType: PaymentsResponse.self) { res in
                if res.status == "success" {
                    contextModel.delete(card)
                    try! contextModel.save()
                }
            }
            
        }
    }
    
    func selectCard(cardselect: CardSD){
        for card in cards {
            if card.id != cardselect.id {
                card.status = false
                card.token = nil
            }
        }
        
        cardselect.status = true
        try! contextModel.save()
        dismiss()
    }
}

extension CVVCode {
    func selectCard(cardselect: CardSD){
        let mercadoPagoData: [String: Any] = [
            "card_id" : cardselect.id,
            "security_code" : cvv
        ]
        
        api.mercagoPago(url: "card_tokens", method: "POST", body: mercadoPagoData, ofType: CardTokens.self) { res in
            for card in cards {
                card.status = false
                card.token = nil
            }
            
            cardselect.token = res.id
            cardselect.status = true
            try! contextModel.save()
            cvv = ""
            dismiss()
        }
    }
}
