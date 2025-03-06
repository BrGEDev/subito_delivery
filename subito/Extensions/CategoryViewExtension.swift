//
//  CategoryViewExtension.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 31/10/24.
//

import SwiftUI

extension CategoryView {
    func loadEstablishments() {
        load = true
        api.fetch(
            url: "establishments/\(id_category)", method: "GET",
            ofType: GetEstablishmentsResponse.self
        ) { res, status in
            if status {
                withAnimation {
                    load = false
                }

                if res!.status == "success" {
                    establishments.removeAll()
                    for establishment in res!.data! {
                        establishments.append(
                            Item(
                                id_restaurant: establishment.id_restaurant,
                                title: establishment.name_restaurant,
                                image: establishment.picture_logo ?? "",
                                establishment: establishment
                                    .picture_establishment
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

    var filteredLocales: [Item] {
        let establishments = establishments

        if searchEstablishments.isEmpty {
            return establishments
        } else {
            return establishments.filter {
                let name = $0.title
                if name.isEmpty {
                    return false
                }
                return name.localizedCaseInsensitiveContains(
                    searchEstablishments)
            }
        }
    }
}
