//
//  IndexViewModel.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 27/03/25.
//

import Foundation

final class IndexViewModel: ObservableObject {
    
    let api = ApiCaller()
    @Published var categories: [ModelCategories] = []
    @Published var items: [Item] = []
    
    static let shared = IndexViewModel()
    
    init() {
        loadTypes()
        loadPopularEstablishments()
    }
    
    func loadTypes() {
        api.fetch(
            url: "type_establishments", method: "GET",
            ofType: TypeEstablishmentsResponse.self
        ) { res, status in
            self.categories.removeAll()
            if status {
                if res!.status == "success" {
                    for category in res!.data! {
                        self.categories.append(
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
            url: "getAllEstablishment", method: "GET",
            ofType: PopularEstablishmentsResponse.self
        ) { res, status in
            self.items.removeAll()
                
            if status {
                if res!.status == "success" {
                    self.items = []
                    
                    for establishment in res!.data! {
                        self.items.append(
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
    
}
