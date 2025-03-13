//
//  SearchSiriKit.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 11/03/25.
//

import SwiftUI

struct SearchSiriKit: View {
    @State var search: SearchData?
    
    var body: some View {
        if search != nil {
            if search!.type_establishments!.isEmpty
                && search!.establishments!.isEmpty
                && search!.products!.isEmpty
            {
                VStack {
                    Text("Sin resultados").foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                LazyVStack(alignment: .leading, spacing: 15) {
                    // Categorías encontradas
                    
                    if search!.type_establishments!.isEmpty{
                        
                        Text("Categorías")
                            .font(.title2.bold())
                        
                        LazyVStack {
                            ZStack {
                                VStack {
                                    ScrollView(
                                        .horizontal,
                                        showsIndicators: false
                                    ) {
                                        HStack {
                                            ForEach(
                                                search!.type_establishments!,
                                                id: \.dc_id
                                            ) { item in
                                                Category(
                                                    category:
                                                        ModelCategories(
                                                            id: item
                                                                .dc_id,
                                                            image: item
                                                                .dc_path,
                                                            texto: item
                                                                .dc_name
                                                        )
                                                )
                                                .padding(
                                                    EdgeInsets(
                                                        top: 0,
                                                        leading: 5,
                                                        bottom: 0,
                                                        trailing: 5
                                                    )
                                                )
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        Spacer(minLength: 1)
                    }
                    
                    // Fin de categorías
                    
                    // Establecimientos encontrados
                    
                    if search!.establishments!.isEmpty {
                        Text("Establecimientos")
                            .font(.title2.bold())
                        
                        ScrollView(.horizontal) {
                            LazyHStack(spacing: 10) {
                                ForEach(
                                    search!.establishments!,
                                    id: \.id_restaurant
                                ) { item in
                                    
                                    NavigationLink(
                                        destination: EstablishmentView(
                                            data: item)
                                    ) {
                                        EstablishmentSearchable(
                                            data: item
                                        )
                                    }
                                    
                                }
                            }
                            .padding([.bottom], 20)
                        }
                    }
                    
                    // Fin establecimientos
                    
                    //Productos encontrados
                    
                    if search!.products!.isEmpty {
                        Text("Productos")
                            .font(.title2.bold())
                        
                        ForEach(
                            search!.products!,
                            id: \.pd_id
                        ) { producto in
                            ProductList(
                                data: producto,
                                location: [
                                    "latitude": producto.latitude!,
                                    "longitude": producto
                                        .longitude!,
                                ],
                                estado: .constant(
                                    state(
                                        apertura: producto
                                            .apertura!,
                                        cierre: producto.cierre!
                                    )
                                )
                            )
                        }
                        
                    }
                    
                    // Fin productosq
                }
            }
        } else {
            VStack {
                Text("Sin resultados").foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

extension SearchSiriKit {
    public func state(apertura: String, cierre: String) -> StateEstablishment {
        do {
            let aperturaS = try timeFromString(string: apertura)
            let cierreS = try timeFromString(string: cierre)

            let intervalA = Date.now.timeIntervalSince(aperturaS!)
            let intervalC = Date.now.timeIntervalSince(cierreS!)

            if intervalA > 0 && intervalC < 0 {
                return .open
            } else {
                return .closed
            }
        } catch {
            return .closed
        }
    }
}
