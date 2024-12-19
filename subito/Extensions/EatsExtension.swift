import SwiftUI
import MapKit

extension Eats {
    
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
}

struct Screen {
    static let height = UIScreen.main.bounds.height
    static let width = UIScreen.main.bounds.width
}
