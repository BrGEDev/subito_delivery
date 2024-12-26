//
//  ModalProductoExtension.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 12/12/24.
//

import SwiftUI
import SwiftData

extension ModalProducto {
    func getOffsetY(basedOn geo: GeometryProxy) -> CGFloat {
        let minY = geo.frame(in: .global).minY
        
        let emptySpaceAboveSheet: CGFloat = 40
        if minY <= emptySpaceAboveSheet {
            return 0
        }
        return -minY + emptySpaceAboveSheet
    }
    
    func addToCart(){
        let producto = ProductsSD(id: Int(data.pd_id)!, product: data.pd_name, image: data.pd_image ?? "", descript: data.pd_description, unit_price: Float(data.pd_unit_price)!, amount: count)
        let establishment = CartSD(id: Int(data.pg_establishments_id)!, establishment: data.name_restaurant, latitude: location["latitude"] as! String, longitude: location["longitude"] as! String)
        let id = Int(data.pg_establishments_id)!
        
        var query: FetchDescriptor<CartSD>{
            let descriptor = FetchDescriptor<CartSD>(predicate: #Predicate{
                $0.id == id
            })
            return descriptor
        }
        
        let shoppingCart = [
            "shopping" : [
                "establishment_id" : id,
                "items" : [
                    [
                        "product_id" : data.pd_id,
                        "quantity" : count
                    ]
                ]
            ]
        ]
        
        let inCart = try! context.fetch(query).first
        if inCart != nil {
            let check = {
                for product in inCart!.products {
                    if product.id == Int(data.pd_id) {
                        product.amount = count
                        return true
                    }
                }
                
                return false
            }
            
            if check() == false {
                inCart!.products.append(producto)
            }
            
            api.fetch(url: "shopping/add", method: "POST", body: shoppingCart, token: token, ofType: ShoppingResponse.self) { response in
                if response.status == "success" {
                   
                    try! context.save()
                    dismiss()
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
                
                api.fetch(url: "shopping/add", method: "POST", body: shoppingCart, token: token, ofType: ShoppingResponse.self) { response in
                    if response.status == "success" {
                        
                        try! context.save()
                        dismiss()
                    }
                }
            } else {
                advertencia = true
            }
        }
    }
    
    func saveNew() {
        api.fetch(url: "shopping/remove/cart", method: "POST", token: token, ofType: ShoppingResponse.self) { response in
            if response.status == "success" {
                try! context.delete(model: CartSD.self)
                
                let producto = ProductsSD(id: Int(data.pd_id)!, product: data.pd_name, image: data.pd_image ?? "", descript: data.pd_description, unit_price: Float(data.pd_unit_price)!, amount: count)
                let establishment = CartSD(id: Int(data.pg_establishments_id)!, establishment: data.name_restaurant, latitude: location["latitude"] as! String, longitude: location["longitude"] as! String)
                
                context.insert(establishment)
                establishment.products.append(producto)
                
                let shoppingCart = [
                    "shopping" : [
                        "establishment_id" : data.pg_establishments_id,
                        "items" : [
                            [
                                "product_id" : data.pd_id,
                                "quantity" : count
                            ]
                        ]
                    ]
                ]
                
                api.fetch(url: "shopping/add", method: "POST", body: shoppingCart, token: token, ofType: ShoppingResponse.self) { response in
                    if response.status == "success" {
                        
                        
                        try! context.save()
                        dismiss()
                    }
                }
            }
        }
    }
}
