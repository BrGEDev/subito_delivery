import MapKit
import SwiftData
import SwiftUI

extension Eats {
    func listeners() {
        socket.socket.on("orderDelivery") { data, ack in
            
            let dataArray = data as NSArray
            let dataString = dataArray[0] as! NSDictionary
            
            if dataString["response"] != nil {
                let id_order = dataString["orderId"] as? NSNumber ?? 0
                let orders = id_order.intValue
                
                let order = FetchDescriptor<TrackingSD>(
                    predicate: #Predicate {
                        $0.order == orders
                    })
                
                let query = try! context.fetch(order).first
                
                if query != nil {
                    if dataString["response"] as! NSNumber == 1
                    {
                        pendingModal = false
                        
                        do {
                            currentDeliveryState = .preparation
                            activityIdentifier =
                            try DeliveryActivity.startActivity(
                                deliveryStatus: .preparation,
                                establishment: query!.establishment,
                                estimaed: query!.estimatedTime)
                        } catch {
                            print("Murió el activity")
                        }
                        
                        loadOrders()
                        
                        notifications.dispatchNotification(
                            title: "Orden aceptada",
                            body:
                                "El establecimiento aceptó tu pedido y está en preparación"
                        )
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            if !path.isEmpty {
                                path.removeLast()
                            }
                            
                            path.append(id_order.stringValue)
                        }
                    } else {
                        pendingModal = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            alert = true
                            alertTitle = "Pedido rechazado"
                            alertMessage = "El establecimiento rechazó tu pedido. Puedes comunicarte con Call Center para más información o intentarlo más tarde."
                        }
                    }
                }
            }
        }
    }

    func loadTypes() {
        api.fetch(
            url: "type_establishments", method: "GET",
            ofType: TypeEstablishmentsResponse.self
        ) { res in
            categories.removeAll()
            if res.status == "success" {
                for category in res.data! {
                    categories.append(
                        ModelCategories(
                            id: category.dc_id, image: category.dc_path,
                            texto: category.dc_name))
                }
            }
        }
    }

    func loadPopularEstablishments() {
        api.fetch(
            url: "mostPopularEstablishments", method: "GET",
            ofType: PopularEstablishmentsResponse.self
        ) { res in
            items.removeAll()
            if res.status == "success" {
                
                for establishment in res.data! {

                    items.append(
                        Item(
                            id_restaurant: establishment.id_restaurant,
                            title: establishment.name_restaurant,
                            image: establishment.picture_logo ?? "",
                            establishment: establishment.picture_establishment
                                ?? "", address: establishment.address,
                            latitude: establishment.latitude,
                            longitude: establishment.longitude,
                            apertura: establishment.apertura,
                            cierre: establishment.cierre
                        )
                    )
                }
            }
        }
    }
    
    func loadLocationEstablishments() {
        let data = [
            "latitude" : directionSelected?.latitude ?? "",
            "longitude" : directionSelected?.longitude ?? ""
        ]
        
        locatedEstablishment = []
        api.fetch(url: "establishmentForLocation", method: "POST", body: data, ofType: GetEstablishmentsResponse.self) { res in
            if res.status == "success" {
                withAnimation {
                    locatedEstablishment = res.data!
                }
            }
        }
    }

    func loadOrders() {
        api.fetch(
            url: "orders_in_progress/\(user!.id)", method: "GET",
            token: user!.token, ofType: OrdersResponse.self
        ) { res in
            if res.status == "success" {
                withAnimation {
                    orders = res.data!
                }
            }
        }
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

}

struct Screen {
    static let height = UIScreen.main.bounds.height
    static let width = UIScreen.main.bounds.width
}
