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
    func listenLocation(){
        socket.socket.on("sendLocation") { data, ack in
            if orderDetails != nil {
                if orderDetails!.order!.id_delivery != nil {
                    let dataArray = data as NSArray
                    let dataString = dataArray[0] as! NSDictionary
                    
                    let id_order = "\(dataString["orderId"]!)"
                    
                    if id_order == String(orderDetails!.order!.id_order) {
      
                        
                        repartidorCoords = CLLocationCoordinate2D(
                            latitude: CLLocationDegrees(Double("\(dataString["latitude"]!)")!),
                            longitude: CLLocationDegrees(Double("\(dataString["longitude"]!)")!)
                        )
                        
                        if orderDetails!.order!.id_status != "22" {
                            withAnimation {
                                coords = .region(MKCoordinateRegion(center: repartidorCoords!, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)))
                            }
                        }
                    }
                }
            }
        }
        
        socket.socket.on("orderCanceled") { data, ack in

            
            if orderDetails != nil  {
                let dataArray = data as NSArray
                let dataString = dataArray[0] as! NSDictionary
                
                let id_order = "\(dataString["orderId"]!)"
                
                if orderDetails!.order!.id_order == id_order {
                    statusString = "Orden cancelada por el establecimiento"
                    status = 39
                    reasonCancel = "\(dataString["reason"] as! String)"
                }
            }
        }
        
        socket.socket.on("responseAutoAsign") { data, ack in
            print(data)
        }
    }
    
    func detailOrder(){
        api.fetch(url: "orders/details/\(order)", method: "GET", token: user!.token, ofType: DetailOrderResponse.self) { res in
            if res.status == "success" {
                let data = res.data!
                
                
                orderDetails = data
                statusString = orderDetails?.order?.status ?? "Cargando..."
                
                clientCoords = CLLocationCoordinate2D(
                    latitude: CLLocationDegrees(Double(data.order!.client_latitude)!),
                    longitude: CLLocationDegrees(Double(data.order!.client_longitude)!)
                )
                
                establishmentCoords = CLLocationCoordinate2D(
                    latitude: CLLocationDegrees(Double(data.order!.establishment_latitude)!),
                    longitude: CLLocationDegrees(Double(data.order!.establishment_longitude)!)
                )
                
                withAnimation {
                    coords = .region(MKCoordinateRegion(center: establishmentCoords!, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)))
                }

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
                listenLocation()
                
                if data.order!.id_delivery != nil {
                    fetchDelivery(data.order!.id_delivery!)
                }
            }
        }
    }
    
    private func fetchDelivery(_ id: String) {
        api.fetch(url: "location/delivery/\(id)", method: "GET", ofType: LocationResponse.self) { res in
            if res.status == "success" {
                repartidorCoords = CLLocationCoordinate2D(
                    latitude: CLLocationDegrees(Double(res.data!.latitude)!),
                    longitude: CLLocationDegrees(Double(res.data!.longitude)!)
                )
                
                if orderDetails!.order!.id_status != "22" {
                    withAnimation {
                        coords = .region(MKCoordinateRegion(center: repartidorCoords!, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)))
                    }
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
