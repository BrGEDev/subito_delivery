//
//  PrePurchaseViewModel.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 03/04/25.
//

import Foundation
import MapKit

@MainActor
final class PrePurchaseViewModel: ObservableObject {
    let api = ApiCaller()
    
    static let shared = PrePurchaseViewModel()
    
    @Published var loading = true
    @Published var segment: Int = 0
    @Published var modalPropina: Bool = false
    
    @Published var prepropina: Float = 0
    @Published var propina: Int = 0
    @Published var subtotal: Float = 0
    
    @Published var km_base: Double = 0
    @Published var price_base_km: Double = 0
    @Published var price_km_extra: Double = 0
    
    @Published var percent: Double = 0
    @Published var envio: Float = 40
    
    @Published var payment: Float = 0
    
    @Published var km: Double = 0
    @Published var estimatedTime: String?
        
    func prePurchase(establishments: [CartSD], user: UserSD) {
        if !establishments.isEmpty {
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
            
            api.fetch(url: "pre_purchase", method: "POST", body: datos, token: user.token, ofType: PrePurchaseResponse.self) { res, status in
                if status {
                    self.loading = false
                    
                    if res!.status == "success" {
                        self.percent = Double(res!.data!.establishment.percent)!
                        
                        if res!.data!.establishment.percent == "0" {
                            self.envio = 0
                        }
                        
                        self.km_base = Double(res!.data!.km_base)!
                        self.price_base_km = Double(res!.data!.price_base_km)!
                        self.price_km_extra = Double(res!.data!.price_km_extra)!
                        
                        self.loadPayment(establishments)
                        self.loadTaxes()
                    }
                }
            }
        }
    }
    
    func loadPayment(_ establishments: [CartSD]) {
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
    
    func calcDistance(directionSelected: DirectionSD?, establishments: [CartSD]) {
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
    
    func calcTax() {
        let presubtotal = subtotal + envio
        prepropina =  presubtotal * (Float(propina) / 100)
        payment = prepropina + presubtotal
    }
}
