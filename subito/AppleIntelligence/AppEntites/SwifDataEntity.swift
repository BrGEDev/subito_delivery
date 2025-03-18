//
//  SwifDataEntity.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 14/03/25.
//

import SwiftData
import Foundation

final class SwifDataEntity: NSObject, ObservableObject {
    private var models: [any PersistentModel.Type] = [
        UserSD.self, DirectionSD.self, CartSD.self, ProductsSD.self,
        CardSD.self, TrackingSD.self,
    ]

    lazy public var container: ModelContainer = {
        let schema = Schema(models)

        let conf = ModelConfiguration(
            schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [conf])
        } catch {
            fatalError(
                "Could not create ModelContainer: \(error.localizedDescription)"
            )
        }
    }()

    lazy public var context: ModelContext = ModelContext(container)
    
    func deleteCart() {
        try! context.delete(model: CartSD.self)
        try! context.save()
    }
    
}
