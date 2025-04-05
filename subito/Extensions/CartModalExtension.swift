//
//  CartModalExtension.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 12/12/24.
//

import SwiftUI
import SwiftData

extension CartModal {
    func loadPayment() -> Float {
        var sum: Float = 0
        
        for est in establishments {
            for product in est.products {
                sum += Float(product.amount) * product.unit_price
            }
        }
        
        return sum
    }
    
    func deleteAll() {
        var query: FetchDescriptor<UserSD> {
            return FetchDescriptor<UserSD>()
        }
        let user = try! context.fetch(query).first!
        
        loading = true
        api.fetch(url: "shopping/remove/cart", method: "POST", token: user.token, ofType: ShoppingModResponse.self) { res, status in
            loading = false
            if status {
                if res!.status == "success"{
                    try! context.delete(model: CartSD.self)
                    try! context.save()
                } else  {
                }
            }
        }
    }
}

extension productoView{
    func delete(product: ProductsSD){
        var query: FetchDescriptor<UserSD> {
            return FetchDescriptor<UserSD>()
        }
        let user = try! context.fetch(query).first!
        
        let data = [
            "items" : [
                [
                    "product_id": product.id
                ]
            ]
        ]
        
        loading = true
        api.fetch(url: "shopping/remove/product", method: "POST", body: data, token: user.token, ofType: ShoppingModResponse.self) { res, status in
            loading = false
            if status {
                if res!.status == "success"{
                    context.delete(product)
                    onDelete.toggle()
                    try! context.save()
                    
                    var est: FetchDescriptor<CartSD>{
                        let descriptor = FetchDescriptor<CartSD>(predicate: #Predicate{
                            $0.id == establishment
                        })
                        return descriptor
                    }
                    
                    let query = try! context.fetch(est).first!
                    
                    if query.products.count == 0{
                        try! context.delete(model: CartSD.self)
                        try! context.save()
                    }
                }
            }
        }
    }
}
