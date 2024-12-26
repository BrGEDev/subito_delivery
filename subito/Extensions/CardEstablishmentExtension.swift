//
//  CardEstablishmentExtension.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 13/11/24.
//
import Foundation
import SwiftUI

extension CardEstablishment {
    public func loadProductos() {
        api.fetch(url: "products/\(data.id_restaurant)", method: "GET", ofType: ProductsResponse.self){ res in
            if res.status == "success" {
                productos = res.data!
            }
        }
    }
    
    public func loadCategories() {
        api.fetch(url: "products/categories/\(data.id_restaurant)", method: "GET", ofType: ProductCategoryResponse.self){ res in
            if res.status == "success" {
                productosC = res.data!
            }
        }
    }
    
    var filteredLocales: [Product] {
        let products = productos
        
        if searchProducto.isEmpty {
            return products
        } else {
            return products.filter {
                let name = $0.pd_name
                if name.isEmpty {
                    return false
                }
                return name.localizedCaseInsensitiveContains(searchProducto)
            }
        }
    }
}

extension ModalRestaurants {
    public func loadProductos() {
        api.fetch(url: "products/\(data.id_restaurant)", method: "GET", ofType: ProductsResponse.self){ res in
            if res.status == "success" {
                productos = res.data!
            }
        }
    }
    
    public func loadCategories() {
        api.fetch(url: "products/categories/\(data.id_restaurant)", method: "GET", ofType: ProductCategoryResponse.self){ res in
            if res.status == "success" {
                productosC = res.data!
            }
        }
    }
    
    var filteredLocales: [Product] {
        let products = productos
        
        if searchProducto.isEmpty {
            return products
        } else {
            return products.filter {
                let name = $0.pd_name
                if name.isEmpty {
                    return false
                }
                return name.localizedCaseInsensitiveContains(searchProducto)
            }
        }
    }
}
