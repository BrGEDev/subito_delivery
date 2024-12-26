//
//  OrderDetailExtension.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 19/12/24.
//

import MapKit
import SwiftUI
import Foundation

extension OrderDetail {
    func detailOrder(){
        api.fetch(url: "orders/details/\(order.id_order)", method: "GET", token: user!.token, ofType: DetailOrderResponse.self) { res in
            if res.status == "success" {
                let data = res.data!
                
                orderDetails = data
                clientCoords = CLLocationCoordinate2D(
                    latitude: CLLocationDegrees(Double(data.order!.client_latitude)!),
                    longitude: CLLocationDegrees(Double(data.order!.client_longitude)!)
                )
                
                establishmentCoords = CLLocationCoordinate2D(
                    latitude: CLLocationDegrees(Double(data.order!.establishment_latitude)!),
                    longitude: CLLocationDegrees(Double(data.order!.establishment_longitude)!)
                )
                
                coords = .region(MKCoordinateRegion(center: establishmentCoords!, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)))

                do {
                    let date = try dateFromString(string: data.order!.created_at)
                    let time = data.order!.time_order.split(separator: ":")
                    var cal = Calendar.current
                    cal.locale = Locale(identifier: "es_MX")
                    var newtime = cal.date(byAdding: .hour, value: Int(time[0])!, to: date!)!
                    newtime = cal.date(byAdding: .minute, value: Int(time[1])!, to: newtime)!
                    fetchRoute(client: clientCoords!, establishment: establishmentCoords!, editDate: newtime)
                } catch {
                    print("Error parsing date")
                }
            }
        }
    }
    
    func fetchRoute(client: CLLocationCoordinate2D, establishment: CLLocationCoordinate2D, editDate: Date) {
        let request = MKDirections.Request()
        
        let destination = MKMapItem(placemark: MKPlacemark(coordinate: client))
        
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: establishment))
        request.destination = destination
        
        Task {
            let result = try? await MKDirections(request: request).calculate()
            
            let timeExpect = result?.routes.first?.expectedTravelTime ?? 0
            let hours = Int(timeExpect) / 3600
            let minutes = (Int(timeExpect) / 60) % 60
            var calendar = Calendar.current
            calendar.locale = Locale(identifier: "es_MX")
            
            var date = calendar.date(byAdding: .minute, value: minutes, to: editDate)
            date = calendar.date(byAdding: .hour, value: hours, to: date!)
            
            estimatedTime = date!.formatted(date: .omitted, time: .shortened)
        }
    }
    
    func callto(phone: String) {
        guard let url = URL(string:"telprompt://\(phone)"),
              UIApplication.shared.canOpenURL(url) else { return }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    private func dateFromString(string: String) throws -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_MX")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS"
        return formatter.date(from: string)
    }
}
