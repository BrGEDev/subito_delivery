//
//  HistoryOrderModel.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 13/03/25.
//

import Foundation
import SwiftData
import SwiftUI

final class HistoryOrderModel: ObservableObject {
    @Published var orders: [HistoryData] = []
    @Published var loading: Bool = false
    var context: ModelContext
    
    let api = ApiCaller()
    
    init(context: ModelContext) {
        self.context = context
        
        loadHistory()
    }
    
    func loadHistory(){
        
        let user = FetchDescriptor<UserSD>()
        let userQuery = try! context.fetch(user).first
        
        loading = true
        
        api.fetch(url: "orders/\(userQuery?.id ?? 0)", method: "GET", ofType: HistoryResponse.self) { res, status in
            
            withAnimation {
                self.loading = false
            }
            
            if status {
                if res!.status == "success" {
                    self.orders = res!.data!
                }
            }
        }
    }
}
