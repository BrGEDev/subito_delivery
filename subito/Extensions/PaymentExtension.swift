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
    func prePurchase() {
        
        var id_products: [Int] = []
        establishments.forEach { est in
            est.products.forEach { product in
                id_products.append(product.id)
            }
        }
        
        let datos: [String:Any] = [
            "data" : [
                "id_establishment": establishments[0].id,
                "id_products" : id_products
            ]
        ]
        
        
        let user = FetchDescriptor<UserSD>()
        let userQuery = try! self.context.fetch(user).first!.token
        
        api.fetch(url: "pre_purchase", method: "POST", body: datos, token: userQuery, ofType: PrePurchaseResponse.self) { res, status in
            if status {
                withAnimation {
                    loading = false
                }
                
                if res!.status == "success" {
                    percent = Double(res!.data!.establishment.percent)!
                    
                    if res!.data!.establishment.percent == "0" {
                        envio = 0
                    }
                    
                    km_base = Double(res!.data!.km_base)!
                    price_base_km = Double(res!.data!.price_base_km)!
                    price_km_extra = Double(res!.data!.price_km_extra)!
                    
                    calcDistance()
                    loadPayment()
                    loadTaxes()
                }
            }
        }
    }
    
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
        
        progress = true
        
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
            "data" : [
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
                    "total": subtotal,
                    "tip": ceil(prepropina),
                    "shipping_cost": envio,
                    "distance_km": km,
                    "text_detail": detail
                ]
            ]
        ]
        
        let user = FetchDescriptor<UserSD>()
        let userQuery = try! self.context.fetch(user).first!.token

        api.fetch(url: "checkout", method: "POST", body: data, token: userQuery, ofType: CheckoutResponse.self) { res, status in
            if status {
                if res!.status == "success" {
                    progress = false
                    isPresented.toggle()
                    pendingOrderModel.socket.socket.emit("orderDelivery", ["orderId": res!.data!.orderId, "establishmentId": res!.data!.establishmentId])

                    let order = TrackingSD(id: UUID(), order: res!.data!.orderId, establishment: establishments[0].establishment, estimatedTime: estimatedTime ?? "0")
                    
                    paymentsSelected?.token = nil
                    context.insert(order)
                    
                    pendingOrderModel.pendingModal = true
                    pendingOrderModel.listeners(order: order, router: router, context: context)
                    dismiss()
                } else {
                    progress = false
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        error = true
                    })
                }
            } else {
                progress = false
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    error = true
                })
            }
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
                    
                if percent != 0 {
                    let envio_cal = Float(km <= km_base ? price_base_km : ((km - km_base) * price_km_extra) + price_base_km)
                    envio = envio_cal * Float(percent) / 100
                }
                
                let timeExpect = result?.routes.first?.expectedTravelTime ?? 0
                let hours = Int(timeExpect) / 3600
                let minutes = (Int(timeExpect) / 60) % 60
                var calendar = Calendar.current
                calendar.locale = Locale(identifier: "es_MX")
                
                var date = calendar.date(byAdding: .minute, value: minutes, to: Date())
                date = calendar.date(byAdding: .hour, value: hours, to: date!)
                estimatedTime = date!.formatted(date: .omitted, time: .shortened)
                
                calcTax()
            }
        } else {
            calcTax()
        }
    }
}

extension PaymentMethod {
    func getPaymentMethod() {
        print(user!.token)
        api.fetch(
            url: "payment-methods", method: "POST", token: user!.token,
            ofType: PaymentMethodResponse.self
        ) { res, status in
            if status {
                if res!.status == "success" {
                    if res!.data!.count != 0 {
                        for card in res!.data! {
                            let query = cards.first(where: { $0.id == card.id })
                            
                            if query == nil {
                                let newCard = CardSD(
                                    id: card.id, last_four: card.last_four_digits,
                                    card_type: card.issuer.name ?? card.payment_method.name,
                                    expiry:
                                        "\(card.expiration_month)/\(card.expiration_year)",
                                    brand: card.payment_method.secure_thumbnail,
                                    name: card.cardholder.name ?? "",
                                    token: nil)
                                
                                contextModel.insert(newCard)
                            }
                        }
                        
                        try! contextModel.save()
                    }
                }
            }
        }
    }

    func deleteCard(offsets: IndexSet) {
        for index in offsets {
            let card = cards[index]
            
            api.fetch(url: "payment-methods/delete", method: "POST", body: ["payment_method_id": card.id], token: user!.token, ofType: PaymentsResponse.self) { res, status in }
            
                contextModel.delete(card)
                try! contextModel.save()
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
        
        api.mercagoPago(url: "card_tokens", method: "POST", body: mercadoPagoData, ofType: CardTokens.self) { res, status in
            if status {
                for card in cards {
                    card.status = false
                    card.token = nil
                }
                
                cardselect.token = res!.id
                cardselect.status = true
                try! contextModel.save()
                cvv = ""
                dismiss()
            }
        }
    }
}

struct TextEditorWithPlaceholder: View {
    @Environment(\.colorScheme)var colorScheme
    @FocusState private var usernameFocus: Bool
    @Binding var text: String
        
    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                VStack {
                    Text("Necesito que mi pedido...")
                        .padding()
                        .background(Color.clear)
                        .opacity(0.6)
                    Spacer()
                }
            }
            
            VStack {
                TextEditor(text: $text)
                    .padding()
                    .frame(minHeight: 150)
                    .opacity(text.isEmpty ? 0.85 : 1)
                    .focused($usernameFocus)
                Spacer()
            }
        }
    }
}
