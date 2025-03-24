//
//  CardEstablishmentExtension.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 13/11/24.
//
import Foundation
import SwiftUI

func timeFromString(string: String) throws -> Date? {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "es_MX")
    formatter.dateFormat = "d/M/yyyy HH:mm:ss"
    let date = "\(Date.now.formatted(date: .numeric, time: .omitted)) \(string)"
    return formatter.date(from: date)
}

extension CardEstablishment {
    public func loadProductos() {
        api.fetch(url: "products/\(data.id_restaurant)", method: "GET", ofType: ProductsResponse.self){ res, status in
            if status {
                loading = false
                
                if res!.status == "success" {
                    productos = res!.data!
                }
            } else {
                
            }
        }
    }
    
    public func loadCategories() {
        api.fetch(url: "products/categories/\(data.id_restaurant)", method: "GET", ofType: ProductCategoryResponse.self){ res, status in
            if status {
                if res!.status == "success" {
                    productosC = res!.data!
                }
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
    
    public func loadInfo() {
        do {
            let aperturaS = try timeFromString(string: data.apertura)
            let cierreS = try timeFromString(string: data.cierre == "00:00:00" ? "23:59:59" : data.cierre)
            
            let intervalA = Date.now.timeIntervalSince(aperturaS!)
            let intervalC = Date.now.timeIntervalSince(cierreS!)
            
            if intervalA > 0 && intervalC < 0 {
                estado = .open
            } else {
                estado = .closed
            }
            
            apertura = aperturaS!.formatted(date: .omitted, time: .shortened)
            cierre = cierreS!.formatted(date: .omitted, time: .shortened)
        } catch {
            print("Error parsing time: \(error)")
        }
    }
}

extension EstablishmentView {
    
    func getOffsetY(basedOn geo: GeometryProxy) -> CGFloat {
        
        let minY = geo.frame(in: .global).minY
        
        let emptySpaceAboveSheet: CGFloat = -30
        if minY <= emptySpaceAboveSheet {
            return 0
        }
        return -minY + emptySpaceAboveSheet
    }
    
    public func loadProductos() {
        api.fetch(url: "products/\(data.id_restaurant)", method: "GET", ofType: ProductsResponse.self){ res, status in
            if status {
                loading = false
                
                if res!.status == "success" {
                    productos = res!.data!
                }
            } else {
                
            }
        }
    }
    
    public func loadCategories() {
        api.fetch(url: "products/categories/\(data.id_restaurant)", method: "GET", ofType: ProductCategoryResponse.self){ res, status in
            if status {
                if res!.status == "success" {
                    productosC = res!.data!
                }
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
    
    public func loadInfo() {
        do {
            let aperturaS = try timeFromString(string: data.apertura)
            let cierreS = try timeFromString(string: data.cierre == "00:00:00" ? "23:59:59" : data.cierre)
            
            let intervalA = Date.now.timeIntervalSince(aperturaS!)
            let intervalC = Date.now.timeIntervalSince(cierreS!)
            
            if intervalA > 0 && intervalC < 0 {
                estado = .open
            } else {
                estado = .closed
            }
            
            apertura = aperturaS!.formatted(date: .omitted, time: .shortened)
            cierre = cierreS!.formatted(date: .omitted, time: .shortened)
        } catch {
            print("Error parsing time: \(error)")
        }
    }
}
