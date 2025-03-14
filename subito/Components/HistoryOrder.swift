//
//  HistoryOrder.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 13/03/25.
//

import SwiftData
import SwiftUI

struct HistoryOrder: View {
    @Query var query: [UserSD]
    var user: UserSD? { query.first }

    @StateObject var api = ApiCaller()
    
    @State var selectSort: String = "Entregado"
    @State var selectView: Int = 1
    
    @State var loading: Bool = true
    
    @ObservedObject var historyModel: HistoryOrderModel
    
    init(context: ModelContext) {
        self.historyModel = HistoryOrderModel(context: context)
    }
    
    let adaptiveColumn = [
        GridItem(.adaptive(minimum: 140))
    ]
    
    var body: some View {
        ScrollView {
            if historyModel.loading {
                ZStack {
                    Spacer().containerRelativeFrame([.horizontal, .vertical])
                    VStack {
                        ProgressView(){
                            Text("Cargando historial...")
                        }
                    }
                }
            } else {
                if selectView == 1 {
                    ListView
                } else {
                    GridView
                }
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .navigationTitle("Historial de pedidos")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Section {
                        Picker("Vista", selection: $selectView.animation()) {
                            Label("Lista", systemImage: "list.bullet").tag(1)
                            Label("Cuadrícula", systemImage: "square.grid.2x2").tag(2)
                        }
                    }
                    Section {
                        Menu {
                            Picker("Ordenar", selection: $selectSort.animation()) {
                                Text("Entregado").tag("Entregado")
                                Text("Pago rechazado").tag("Pago rechazado")
                                Text("Rechazado por establecimiento").tag("Rechazado por establecimiento")
                            }
                        } label: {
                            Label(
                                title: { Text("Ordenar por") },
                                icon: { Image(systemName: "arrow.up.arrow.down") }
                            )
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .refreshable {
            historyModel.loadHistory()
        }
    }
}
