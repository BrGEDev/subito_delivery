//
//  EatsModel.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 20/03/25.
//

import Foundation
import SwiftData
import SwiftUI

enum SaveToType {
    case all, one(product: ProductosFavData)
}

final class EatsModel: ObservableObject {
    private var api = ApiCaller()
    static var shared = EatsModel()
    
    private let token = UserDefaults().string(forKey: "tokenUser") ?? ""
    @Published var favIntelligence: FavData? = nil
    @Published var locatedEstablishment: [Establishments] = []
    
    init() {
        fetchFavIntelligence()
    }
    
    func fetchFavIntelligence() {
        api.fetch(url: "getFavouritesIntent", method: "GET", token: token, ofType: FavResponse.self) { res, status in
            if status {
                if res!.status == "success" {
                    self.favIntelligence = res!.data!
                }
            }
        }
    }
    
    func addToCart(context: ModelContext, type: SaveToType, completion: @escaping (Bool) -> Void) {
        let query = FetchDescriptor<UserSD>()
        let token = try! context.fetch(query).first!.token
        
        let establishment = CartSD(id: Int(favIntelligence!.establecimiento.id)!, establishment: favIntelligence!.establecimiento.nombre, latitude: favIntelligence!.establecimiento.latitude, longitude: favIntelligence!.establecimiento.longitude)
        
        let id = Int(favIntelligence!.establecimiento.id)!
        
        var query2: FetchDescriptor<CartSD>{
            let descriptor = FetchDescriptor<CartSD>(predicate: #Predicate{
                $0.id == id
            })
            return descriptor
        }
        
        switch type {
                
            case .all:
                var productsArray: [ProductsSD] = []
                favIntelligence?.productos.forEach { product in
                    productsArray.append(ProductsSD(id: product.id, product: product.nombre, image: product.imagen, descript: product.nombre, unit_price: Float(product.precio)!, amount: product.promedioCompra))
                }
                
                let inCart = try! context.fetch(query2).first
                if inCart != nil {
                    productsArray.forEach { prod in
                        inCart!.products.append(prod)
                    }
                    
                    try! context.save()
                    completion(true)
                    return
                } else {
                    var query2: FetchDescriptor<CartSD>{
                        return FetchDescriptor<CartSD>()
                    }
                    
                    let get = try! context.fetch(query2)
                    
                    let check = {
                        for est in get {
                            if est.id != id {
                                return false
                            }
                        }
                        
                        return true
                    }
                    
                    if check() {
                        context.insert(establishment)
                        productsArray.forEach { prod in
                            establishment.products.append(prod)
                        }
                        
                        try! context.save()
                        completion(true)
                    } else {
                        completion(false)
                        return
                    }
                }
                break
            case .one(let product):
                let producto = ProductsSD(id: product.id, product: product.nombre, image: product.imagen, descript: product.nombre, unit_price: Float(product.precio)!, amount: product.promedioCompra)
                
                let shoppingCart = [
                    "shopping" : [
                        "establishment_id" : id,
                        "items" : [
                            [
                                "product_id" : product.id,
                                "quantity" : 1
                            ]
                        ]
                    ]
                ]
                
                let inCart = try! context.fetch(query2).first
                if inCart != nil {
                    let check = {
                        for producto in inCart!.products {
                            if producto.id == product.id {
                                producto.amount = product.cantidadCompra
                                return true
                            }
                        }
                        
                        return false
                    }
                
                    if check() == false {
                        inCart!.products.append(producto)
                    }
                    
                    api.fetch(url: "shopping/add", method: "POST", body: shoppingCart, token: token, ofType: ShoppingModResponse.self) { res, status in
                        if status {
                            if res!.status == "success" {
                                try! context.save()
                                completion(true)
                                return
                            }
                        }
                    }
                } else {
                    var query2: FetchDescriptor<CartSD>{
                        return FetchDescriptor<CartSD>()
                    }
                    
                    let get = try! context.fetch(query2)
                    
                    let check = {
                        for est in get {
                            if est.id != id {
                                return false
                            }
                        }
                        
                        return true
                    }
                    
                    if check() {
                        context.insert(establishment)
                        establishment.products.append(producto)
                        
                        api.fetch(url: "shopping/add", method: "POST", body: shoppingCart, token: token, ofType: ShoppingModResponse.self) { response, status in
                            if status {
                                if response!.status == "success" {
                                    try! context.save()
                                    completion(true)
                                    return
                                }
                            }
                        }
                    } else {
                        completion(false)
                        return
                    }
                }
                
                break
        }
    }
    
    func loadLocationEstablishments(directionSelected: DirectionSD) {
        let data = [
            "latitude" : directionSelected.latitude,
            "longitude" : directionSelected.longitude
        ]
        
        api.fetch(url: "establishmentForLocation", method: "POST", body: data, ofType: GetEstablishmentsResponse.self) { res, status in
            if status {
                if res!.status == "success" {
                    withAnimation {
                        self.locatedEstablishment = res!.data!
                    }
                }
            }
        }
    }
}
