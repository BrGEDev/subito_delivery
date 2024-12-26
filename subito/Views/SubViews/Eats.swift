
//
//  Eats.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 01/10/24.
//

import SwiftUI
import SwiftData

struct Eats: View {
    @State var currentDeliveryState: DeliveryState = .pending
    @State var activityIdentifier: String = ""
    
    @Environment(\.modelContext) var context
    @Environment(\.colorScheme) var colorScheme
    var socket: SocketService
    
    @State var activeID = UUID()
    @State var isExpand: Bool = false
    
    @StateObject var api: ApiCaller = ApiCaller()
    @StateObject var notifications: Notifications = Notifications()
    
    @State var categories: [ModelCategories] = []
    @State var items: [Item] = []
    @State var orders: [Orders] = []
    
    @State var searchText: String = ""
    @State var searchableText: Bool = false
    
    @State var cartModal: Bool = false
    @State var directionModal: Bool = false
    @State var seeAccount: Bool = false
    
    @Query var userData: [UserSD]
    var user: UserSD? { userData.first }
    @Query(filter: #Predicate<DirectionSD> { direction in
        direction.status == true
    }) var directions: [DirectionSD]
    private var directionSelected: DirectionSD? { directions.first }

    private let adaptiveColumn = [
        GridItem(.adaptive(minimum: 140))
    ]
    
    var body: some View {
        NavigationView{
            ZStack(alignment:.top){
                if searchableText {
                    HStack{
                        TextField("Buscar en Súbito Delivery", text: $searchText)
                            .padding()
                            .frame(height: 50)
                            .background(.regularMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .multilineTextAlignment(.center)
                        
                        
                        Button(action:{
                            searchText = ""
                            searchableText = false
                        }){
                            Text("Cancelar")
                        }
                        .foregroundStyle(Color.accentColor)
                    }
                    .zIndex(20)
                    .padding()
                    .background(Material.bar)
                }
                
                ScrollView{
                    
                    if !searchableText{
                        HStack(alignment: .center){
                            VStack{
                                Text("Hola, \(user?.name ?? "User")")
                                    .font(.largeTitle)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .bold()
                                    .multilineTextAlignment(.leading)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text(Date.now, style: .date)
                                    .font(.headline)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .foregroundStyle(.secondary)
                                    .bold()
                                    .multilineTextAlignment(.leading)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                seeAccount = true
                            }){
                                Image(.burger)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                                    .clipped()
                            }
                            .sheet(isPresented: $seeAccount){
                                Account()
                            }
                        }
                        .padding([.top, .trailing, .leading])
                        
                        Button(action:{
                            searchableText = true
                        }){
                            Text("Buscar en Súbito Delivery")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .multilineTextAlignment(.center)
                                .foregroundStyle(Color.gray.opacity(0.6))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 15)
                        .padding([.bottom, .trailing, .leading])
                    }
                    
                    LazyVStack{
                        ZStack{
                            VStack{
                                ScrollView(.horizontal, showsIndicators: false) {
                                    if categories.count > 0 {
                                        HStack{
                                            ForEach(categories) { item in
                                                Category(category: item, socket: socket)
                                                    .padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
                                            }
                                        }
                                    }else {
                                        HStack{
                                            ForEach(0..<10) { _ in
                                                SkeletonCellView(width: 65, height: 65)
                                                    .padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
                                            }
                                        }
                                        .blinking(duration: 0.75)
                                    }
                                }
                            }
                        }
                    }
                    .padding([.bottom, .trailing, .leading])
                    .padding(.top, searchableText ? 100 : 0)
                    
                    if !orders.isEmpty {
                        if orders.count == 1 {
                            ForEach(orders, id: \.id_order) { item in
                                if item.status != "Cancelado" {
                                    NavigationLink(destination: OrderDetail(order: item)) {
                                        OrderCard(order: item)
                                    }
                                }
                            }
                        } else {
                            NavigationLink(destination: ListOrders(orders: orders)){
                                ListOrderCard(orders: orders)
                            }
                        }
                    }
                    
                    HomePage()
                    
                    LazyVGrid(columns: adaptiveColumn, spacing: 10){
                        
                        if filteredLocales.count > 0 {
                            ForEach(filteredLocales) { item in
                                GeometryReader { reader in
                                    ModalRestaurants(isExpand: $isExpand, isActive: $activeID, data: item)
                                        .offset(
                                            x: activeID == item.id ? -reader.frame(in: .global).minX : 0,
                                            y: activeID == item.id ? -reader.frame(in: .global).minY : 0
                                        )
                                        .opacity(activeID != item.id && isExpand ? 0 : 1)
                                }
                                .frame(width: isExpand ? Screen.width : Screen.width * 0.45, height: 200)
                            }
                        } else {
                            ForEach(0..<6){ _ in
                                SkeletonCellView(width: Screen.width * 0.45, height: 200)
                                    .blinking(duration: 0.75)
                            }
                        }
                        
                    }
                    .padding()
                   
                }
                .scrollIndicators(.hidden)
            }
            .toolbar(isExpand == true || searchableText == true ? .hidden : .visible, for: .automatic)
            .toolbar(isExpand == true ? .hidden : .visible, for: .tabBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading){
                    Button(action: {
                        directionModal = true
                    }){
                        Image(systemName: "mappin.circle")
                        Text(directionSelected?.full_address ?? "Obteniendo ubicación...")
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .frame(maxWidth: 220)
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing){
                    Button(action: {
                        cartModal = true
                    }){
                        Image(systemName: "cart")
                            .foregroundStyle(.primary)
                    }
                }
            }
            .sheet(isPresented: $cartModal){
                CartModal(isPresented: $cartModal, socket: socket)
            }
            .sheet(isPresented: $directionModal){
                NavigationView{
                    DirectionsModal()
                }
            }
            .onAppear{
                isExpand = false
                activeID = UUID()
                loadTypes()
                loadPopularEstablishments()
                loadOrders()
                listeners()
            }
            .refreshable {
                loadOrders()
                if !isExpand{
                    loadTypes()
                    loadPopularEstablishments()
                }
            }
        }
    }
}
