import MapKit
import SwiftData
import SwiftUI

extension Eats {
    func loadTypes() {
        api.fetch(
            url: "type_establishments", method: "GET",
            ofType: TypeEstablishmentsResponse.self
        ) { res, status in
            categories.removeAll()
            if status {
                if res!.status == "success" {
                    for category in res!.data! {
                        categories.append(
                            ModelCategories(
                                id: category.dc_id, image: category.dc_path,
                                texto: category.dc_name))
                    }
                }
            }
        }
    }

    func loadPopularEstablishments() {
        api.fetch(
            url: "mostPopularEstablishments", method: "GET",
            ofType: PopularEstablishmentsResponse.self
        ) { res, status in
            items.removeAll()
                
            if status {
                if res!.status == "success" {
                    
                    for establishment in res!.data! {

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
    }
    
    func loadLocationEstablishments() {
        let data = [
            "latitude" : directionSelected?.latitude ?? "",
            "longitude" : directionSelected?.longitude ?? ""
        ]
        
        locatedEstablishment = []
        api.fetch(url: "establishmentForLocation", method: "POST", body: data, ofType: GetEstablishmentsResponse.self) { res, status in
            if status {
                if res!.status == "success" {
                    withAnimation {
                        locatedEstablishment = res!.data!
                    }
                }
            }
        }
    }

    func loadOrders() {
        if user?.id != nil {
            api.fetch(
                url: "orders_in_progress/\(user!.id)", method: "GET",
                token: user!.token, ofType: OrdersResponse.self
            ) { res, status in
                if status {
                    if res!.status == "success" {
                        withAnimation {
                            orders = res!.data!
                        }
                    }
                }
            }
        }
    }

}

struct Screen {
    static let height = UIScreen.main.bounds.height
    static let width = UIScreen.main.bounds.width
}
