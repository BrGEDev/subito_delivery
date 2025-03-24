//
//  AppIntents.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 11/03/25.
//

import AppIntents
import SwiftData

//struct SearchInSubito: AppIntent {
//    static var title: LocalizedStringResource = "Buscar en Súbito"
//    static var description: IntentDescription? = .init(stringLiteral: "Buscar productos o establecimientos en Súbito")
//    static var openAppWhenRun: Bool = false
//    
//    @Parameter(title: "producto o establecimiento")
//    var query: String
//    
//    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
//        let api = ApiCaller()
//        
//        let data = [
//            "search" : query
//        ]
//                
//        let result = try await api.fetchAsync(url: "search", method: "POST", body: data, ofType: SearchResponse.self)
//                    
//        guard result != nil else {
//            return .result(dialog: "No se encontraron resultados para \(query)")
//
//        }
//        
//        return .result(dialog: "Buscando \(query)...", view: SearchSiriKit(search: result?.data))
//    }
//}

struct InCartSubito: AppIntent {
    static var title: LocalizedStringResource = "Ver mi carrito en Súbito"
    static var description: IntentDescription? = .init(stringLiteral: "Ver el carrito de compras en Súbito")
    static var openAppWhenRun: Bool = false
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let api = ApiCaller()
        
        let token = UserDefaults().string(forKey: "tokenUser") ?? ""
        
        let result = try await api.fetchAsync(url: "shopping/get", method: "GET", token: token, ofType: ShoppingResponse.self)
        
        guard result != nil else {
            return .result(dialog: "No tienes productos en tu carrito de Súbito")
        }
        
        if result!.data != nil {
            let suma = loadPayment(establishments: result!.data!)
            var productos: [String] = []
            
            for product in result!.data!.order.products {
                productos.append("\(product.pd_quantity) de \(product.pd_name)")
            }
            
            return .result(dialog: "Tienes \(result!.data!.order.products.count) productos en tu carrito de Súbito. El total es de \(Int(ceil(suma))) pesos. Entre tus productos se encuentran \(productos.joined(separator: ", ")).")
        } else {
            return .result(dialog: "No tienes productos en tu carrito de Súbito")
        }
    }
    
    private func loadPayment(establishments: Shopping) -> Float {
        var sum: Float = 0
        
        for est in establishments.order.products {
            sum += Float(est.pd_quantity)! * Float(est.pd_unit_price)!
        }
        
        return sum
    }
}

struct DeleteCartSubito: AppIntent {
    static var title: LocalizedStringResource = "Eliminar carrito de Súbito"
    static var description: IntentDescription? = .init(stringLiteral: "Eliminar el carrito de Súbito")
    static var openAppWhenRun: Bool = false
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let api = ApiCaller()
        let db = SwifDataEntity()
        
        let token = UserDefaults().string(forKey: "tokenUser") ?? ""
        
        let result = try await api.fetchAsync(url: "shopping/remove/cart", method: "POST", token: token, ofType: ShoppingModResponse.self)
        
        if result?.status == "success" {
            db.deleteCart()
            return .result(dialog: "Se limpió correctamente tu carrito de Súbito.")
        }
        
        return .result(dialog: "No se pudo eliminar tu carrito, consulta la aplicación")
    }
}

struct AddFavouriteSubito: AppIntent {
    static var title: LocalizedStringResource = "Agregar mis favoritos de la hora a mi carrito de Súbito"
    static var description: IntentDescription? = .init(stringLiteral: "Agregar tus productos favoritos actuales a tu carrito de Súbito")
    static var openAppWhenRun: Bool = false
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        return .result(dialog: "Se agregaron tus favoritos a tu carrito de Súbito.")
    }
}
