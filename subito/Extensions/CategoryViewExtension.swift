//
//  CategoryViewExtension.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 31/10/24.
//

import SwiftUI

extension CategoryView {
    func loadEstablishments(){
        load = true
        api.fetch(url: "establishments/\(id_category)", method: "GET", ofType: GetEstablishmentsResponse.self){ res, status in
            load = false
            establishments = res!.data ?? []
        }
    }
    
    var filteredLocales: [Establishments] {
        let establishments = establishments
        
        if searchEstablishments.isEmpty {
            return establishments
        } else {
            return establishments.filter {
                let name = $0.name_restaurant
                if name.isEmpty {
                    return false
                }
                return name.localizedCaseInsensitiveContains(searchEstablishments)
            }
        }
    }
}
