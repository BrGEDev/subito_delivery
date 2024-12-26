//
//  CategoryView.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 09/09/24.
//

import SwiftUI


struct CategoryView: View {
    
    @State var categoryTitle: String
    @State var id_category: Int
    @State var establishments: [Establishments] = []
    @State var load: Bool = true
    var socket: SocketService
    
    @State var isExpand: Bool = false
    @State var activeID: String = ""
    @State var cartModal: Bool = false
    
    @State var searchEstablishments: String = ""
    
    @StateObject var api: ApiCaller = ApiCaller()
    
    var body: some View{
        VStack{
            if load{
                ProgressView()
                Text("Cargando...")
            } else {
                if !establishments.isEmpty {
                    ScrollView{
                        VStack(spacing: 30){
                            ForEach(filteredLocales, id: \.id_restaurant){ est in
                                GeometryReader { reader in
                                    CardEstablishment(data: est, isActive: $activeID, isExpand: $isExpand)
                                        .offset(y: activeID ==  est.id_restaurant ? -reader.frame(in: .global).minY : 0)
                                        .opacity(activeID !=  est.id_restaurant && isExpand ? 0 : 1)
                                }
                                .frame(height: Screen.height * 0.45)
                            }
                        }
                    }
                    .scrollDisabled(isExpand)
                } else {
                    VStack{
                        Image(.logo)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                        
                        Text("No hay establecimientos en esta categoría")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: 300, maxHeight:300)
                }
            }
        }
        .refreshable {
            loadEstablishments()
        }
        .toolbar{
            ToolbarItem(placement: .navigationBarTrailing){
                Button(action: {
                    cartModal = true
                }){
                    Image(systemName: "cart")
                        .foregroundStyle(.primary)
                }
                .sheet(isPresented: $cartModal){
                    CartModal(isPresented: $cartModal, socket: socket)
                }
            }
        }
        .toolbar(isExpand ? .hidden : .visible, for: .navigationBar)
        .toolbar(isExpand ? .hidden : .visible, for: .tabBar)
        .navigationTitle(categoryTitle)
        .searchable(text: $searchEstablishments)
        .onAppear{
            loadEstablishments()
        }
        .navigationBarTitleDisplayMode(.large)
    }
}
