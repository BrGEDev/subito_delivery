//
//  SearchItems.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 11/02/25.
//

import SwiftUI

struct SearchItems: View {
    @ObservedObject var searchModel: SearchViewModel

    @State var activeID = UUID()
    @State var isExpand: Bool = false
    @State var loading: Bool = false

    var body: some View {
        if searchModel.loading {
            VStack {
                ProgressView {
                    Text("Buscando...")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            if searchModel.results != nil {
                if searchModel.results!.type_establishments!.isEmpty
                    && searchModel.results!.establishments!.isEmpty
                    && searchModel.results!.products!.isEmpty
                {
                    VStack {
                        Text("Sin resultados").foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 15) {
                            // Categorías encontradas

                            if !searchModel.results!.type_establishments!
                                .isEmpty
                            {

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
                                                        searchModel.results!
                                                            .type_establishments!,
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

                            if !searchModel.results!.establishments!.isEmpty {
                                Text("Establecimientos")
                                    .font(.title2.bold())

                                ScrollView(.horizontal) {
                                    LazyHStack(spacing: 10) {
                                        ForEach(
                                            searchModel.results!
                                                .establishments!,
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

                            if !searchModel.results!.products!.isEmpty {
                                Text("Productos")
                                    .font(.title2.bold())

                                ForEach(
                                    searchModel.results!.products!,
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
                        .padding()
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
}

extension SearchItems {
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
