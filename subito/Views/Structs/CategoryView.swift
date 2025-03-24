//
//  CategoryView.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 09/09/24.
//

import SwiftUI

struct CategoryView: View {
    @ObservedObject var pendingOrderModel = PendingOrderModel.shared

    @State var categoryTitle: String
    @State var id_category: Int
    @State var establishments: [Item] = []
    @State var load: Bool = true

    @State var isExpand: Bool = false
    @State var activeID: String = ""
    @State var cartModal: Bool = false
    @State var pendingModal: Bool = false

    @State var searchEstablishments: String = ""

    @StateObject var api: ApiCaller = ApiCaller()

    var body: some View {
        ScrollView {
            if load {
                ZStack {
                    Spacer().containerRelativeFrame([.horizontal, .vertical])
                    VStack {
                        ProgressView(){
                            Text("Cargando...")
                        }
                    }
                }
            } else {
                if !establishments.isEmpty {
                    if !filteredLocales.isEmpty {
                        LazyVStack(spacing: 30) {
                            ForEach(filteredLocales) { est in
                                GeometryReader { reader in
                                    CardEstablishment(
                                        data: est,
                                        typeModal: .Large,
                                        isActive: $activeID,
                                        isExpand: $isExpand
                                    )
                                    .offset(
                                        y: activeID == est.id_restaurant
                                            ? -reader.frame(in: .global).minY
                                            : 0
                                    )
                                    .opacity(
                                        activeID != est.id_restaurant
                                            && isExpand ? 0 : 1)
                                }
                                .frame(height: Screen.height * 0.45)
                            }
                        }
                    } else {
                        ZStack {
                            Spacer().containerRelativeFrame([.horizontal, .vertical])
                            VStack {
                                Text("Sin resultados")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: 300, maxHeight: 300)
                        }                    }
                } else {
                    ZStack {
                        Spacer().containerRelativeFrame([.horizontal, .vertical])
                        VStack {
                            Image(.logo)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 150, height: 150)
                            
                            Text("No hay establecimientos en esta categoría")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: 300, maxHeight: 300)
                    }
                }
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .scrollDisabled(isExpand)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    cartModal = true
                }) {
                    Image(systemName: "cart")
                        .foregroundStyle(.primary)
                }
                .sheet(isPresented: $cartModal) {
                    CartModal(isPresented: $cartModal)
                }
            }
        }
        .toolbar(isExpand ? .hidden : .visible, for: .navigationBar)
        .toolbar(isExpand ? .hidden : .visible, for: .tabBar)
        .navigationTitle(categoryTitle)
        .searchable(text: $searchEstablishments)
        .onAppear {
            loadEstablishments()
        }
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $pendingOrderModel.pendingModal) {
            PendingOrder()
                .presentationBackgroundInteraction(.disabled)
                .interactiveDismissDisabled(true)
        }
        .refreshable {
            loadEstablishments()
        }
    }
}
