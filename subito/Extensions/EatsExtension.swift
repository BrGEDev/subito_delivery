import SwiftUI
import MapKit
import SwiftData

extension Eats {
    func listeners(){
        socket.socket.on("orderDelivery") { data, ack in
            print(data)
            
            let dataArray = data as NSArray
            let dataString = dataArray[0] as! NSDictionary
            print(dataString["orderId"]!)
            
            
            if dataString["response"] != nil && dataString["response"] as! NSNumber == 1 {
                let id_order = Int(dataString["orderId"] as! String)!
                
                let order = FetchDescriptor<TrackingSD>(predicate: #Predicate{
                    $0.order == id_order
                })
                
                let query = try! context.fetch(order).first
                
                if query != nil {
                    do {
                        loadOrders()
                        notifications.dispatchNotification(title: "Orden aceptada", body: "El establecimiento aceptó tu pedido y está en preparación")
                        
                        currentDeliveryState = .preparation
                        activityIdentifier = try DeliveryActivity.startActivity(
                            deliveryStatus: .preparation, establishment: query!.establishment,
                            estimaed: query!.estimatedTime)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    func loadTypes(){
        api.fetch(url: "type_establishments", method: "GET", ofType: TypeEstablishmentsResponse.self){res in
            categories.removeAll()
            if res.status == "success" {
                for category in res.data!{
                    categories.append(ModelCategories(id: category.dc_id, image: category.dc_path, texto: category.dc_name))
                }
            }
        }
    }
    
    func loadPopularEstablishments(){
        api.fetch(url: "mostPopularEstablishments", method: "GET", ofType: PopularEstablishmentsResponse.self) { res in
            items.removeAll()
            if res.status == "success" {
                for establishment in res.data!{
                    
                    items.append(Item(id_restaurant: establishment.id_restaurant, title:establishment.name_restaurant, image: establishment.picture_logo ?? "", establishment: establishment.picture_establishment ?? "", address: establishment.address, latitude: establishment.latitude, longitude: establishment.longitude))
                }
            }
        }
    }
    
    var filteredLocales: [Item] {
        let establishments = items
        
        if searchText.isEmpty {
            return establishments
        } else {
            return establishments.filter {
                let name = $0.title
                if name.isEmpty {
                    return false
                }
                return name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    func loadOrders(){
        api.fetch(url: "orders_in_progress/\(user!.id)", method: "GET", token: user!.token, ofType: OrdersResponse.self){ res in
            if res.status == "success" {
                orders = res.data!
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
