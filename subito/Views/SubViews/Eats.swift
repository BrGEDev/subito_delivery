//
//  Eats.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 01/10/24.
//

import SwiftUI
import SwiftData

struct Eats: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State var activeID = UUID()
    @State var isExpand: Bool = false
    
    @StateObject var api: ApiCaller = ApiCaller()
    
    @State var categories: [ModelCategories] = []
    @State var items: [Item] = []
    
    @State var searchText: String = ""
    @State var searchableText: Bool = false
    
    @State var cartModal: Bool = false
    @State var directionModal: Bool = false
    @State var seeAccount: Bool = false
    
    @Query var userData: [UserSD]
    private var user: UserSD? { userData.first }
    @Query(filter: #Predicate<DirectionSD> { direction in
        direction.status == true
    }) var directions: [DirectionSD]
    private var directionSelected: DirectionSD? { directions.first }

    private let adaptiveColumn = [
        GridItem(.adaptive(minimum: 120))
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
                                                Category(category: item)
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
            .toolbar{
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
                CartModal(isPresented: $cartModal)
            }
            .sheet(isPresented: $directionModal){
                NavigationView{
                    DirectionsModal()
                }
            }
            .toolbar(isExpand || searchableText ? .hidden : .visible, for: .navigationBar)
            .toolbar(isExpand ? .hidden : .visible, for: .tabBar)
            .onAppear{
                isExpand = false
                activeID = UUID()
                loadTypes()
                loadPopularEstablishments()
                
            }
            .refreshable {
                if !isExpand{
                    loadTypes()
                    loadPopularEstablishments()
                }
            }
        }
    }
}

#Preview {
    Eats()
        .modelContainer(for: [UserSD.self, DirectionSD.self, ProductsSD.self, CartSD.self])
}
