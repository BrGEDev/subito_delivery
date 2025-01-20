//
//  EstablishmentLocated.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 31/12/24.
//

import SwiftUI

struct EstablishmentLocated: View {
    var data: Establishments
    
    var body: some View {
        VStack {
            VStack{
                AsyncImage(
                    url: URL(
                        string:
                            "https://dev-da-pw.mx/APPRISA/\(data.picture_establishment ?? data.picture_logo!)"
                    )
                ) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    SkeletonCellView(
                        width: Screen.width, height: 250
                    )
                    .blinking(duration: 0.75)

                }
            }
            .frame(maxWidth: .infinity, maxHeight: 250)
            
        }
    }
}

struct EstablishmentView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var data: Establishments
    
    @StateObject var api: ApiCaller = ApiCaller()
    
    @State var productos: [Product] = []
    @State var productosC: [ProductCategory] = []
    
    @FocusState var searchFocus: Bool
    @State var searchState: Bool = false
    @State var searchProducto: String = ""
    @State var menuSelected: String = "Todos"
    
    @State var screenTitle: String = ""
    @State var categorySelect: Int = 0
    @State var estado: StateEstablishment = .closed
    @State var apertura: String = ""
    @State var cierre: String = ""
    
    var body: some View {
        ZStack(alignment:.top){
            ZStack{
                ScrollView(.vertical, showsIndicators: false){
                    VStack(spacing: 5){
                        if !searchState {
                            GeometryReader { imageGeo in
                                LazyVStack{
                                    ZStack(alignment: .top){
                                        ZStack(alignment: .bottom){
                                            VStack {
                                                AsyncImage(url: URL(string: "https://dev-da-pw.mx/APPRISA/\(data.picture_establishment ?? "")")) { image in
                                                    image
                                                        .resizable()
                                                } placeholder: {
                                                    SkeletonCellView(
                                                        width: Screen.width, height: Screen.height * 0.50
                                                    )
                                                    .blinking(duration: 0.75)
                                                }
                                            }
                                            .scaledToFill()
                                            .frame(height: Screen.height * 0.50)
                                            .brightness(-0.3)
                                            
                                            HStack{
                                                VStack(alignment: .center){
                                                    VStack {
                                                        AsyncImage(url: URL(string: "https://dev-da-pw.mx/APPRISA/\(data.picture_logo ?? "")")) { image in
                                                            image
                                                                .resizable()
                                                        } placeholder: {
                                                            ProgressView()
                                                        }
                                                    }
                                                    .frame(width: 120, height: 120)
                                                    .background(Color.white)
                                                    .clipShape(Circle())
                                                    .shadow(color: .black.opacity(0.2), radius: 15)
                                                }
                                                .frame(maxWidth: .infinity)
                                                
                                                Spacer()
                                            }
                                            .offset(y: 15)
                                        }
                                        
                                        HStack{
                                            VStack(alignment: .leading){
                                                Text(data.name_restaurant)
                                                    .font(.system(.largeTitle))
                                                    .lineLimit(1)
                                                    .truncationMode(.tail)
                                                    .bold()
                                                    .foregroundStyle(.white)
                                                    .onAppear {
                                                        screenTitle = "" // <-- hides title when this text is visible
                                                    }
                                                    .onDisappear {
                                                        screenTitle = data.name_restaurant // <-- shows title when this text is not visible
                                                    }
                                            }
                                            .padding(.top, 130)
                                            .padding(.leading, 20)
                                            
                                            Spacer()
                                        }
                                        .frame(maxWidth: Screen.width)
                                    }
                                    .offset(x: 0, y: self.getOffsetY(basedOn: imageGeo))
                                }
                                .frame(maxWidth: Screen.width)
                            }
                            .scaledToFill()
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 20){
                            if searchState {
                                Spacer(minLength: 95)
                            }
                            
                            if !searchState {
                                HStack{
                                    HStack{
                                        Text(menuSelected)
                                            .bold()
                                            .multilineTextAlignment(.leading)
                                            .font(.title2)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        Button(action: {
                                            searchState.toggle()
                                        }){
                                            Image(systemName: "magnifyingglass")
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                    }
                                }
                            }
                            
                            ScrollView(.horizontal, showsIndicators: false){
                                HStack(spacing: 15){
                                    VStack{
                                        Text("Todos")
                                            .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                                    }
                                    .background(categorySelect == 0 ? AnyShapeStyle(Color.accentColor.opacity(0.4)) : AnyShapeStyle(Material.ultraThin))
                                    .clipShape(.capsule)
                                    .onTapGesture{
                                        menuSelected = "Todos"
                                        categorySelect = 0
                                    }
                                    
                                    ForEach(productosC, id: \.pg_id) { item in
                                        VStack{
                                            Text(item.pg_name)
                                                .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                                        }
                                        .background(categorySelect == item.pg_id ? AnyShapeStyle(Color.accentColor.opacity(0.4)) : AnyShapeStyle(Material.ultraThin))
                                        .clipShape(.capsule)
                                        .onTapGesture{
                                            menuSelected = item.pg_name
                                            categorySelect = item.pg_id
                                            
                                        }
                                    }
                                }
                            }
                            .onTapGesture{
                                if searchFocus{
                                    searchFocus = false
                                }
                            }
                            
                            VStack(spacing: 20){
                                if filteredLocales.count != 0 {
                                    ForEach(filteredLocales, id: \.pd_id) { producto in
                                        if categorySelect == producto.pg_id {
                                            ProductList(data: producto, location: ["latitude": data.latitude, "longitude": data.longitude], estado: $estado)
                                        } else if categorySelect == 0{
                                            ProductList(data: producto, location: ["latitude": data.latitude, "longitude": data.longitude], estado: $estado)
                                        }
                                    }
                                } else {
                                    Text("No hay productos disponibles")
                                }
                            }
                            .onTapGesture{
                                if searchFocus{
                                    searchFocus = false
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .animation(Animation.spring(response: 0.5, dampingFraction: 0.9, blendDuration: 0.5), value: searchState)
                    }
                    .padding(.bottom)
                }
                
                if searchState {
                    VStack {
                        HStack{
                            
                            TextField("Buscar en \(data.name_restaurant)", text: $searchProducto)
                                .padding()
                                .frame(height: 50)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .focused($searchFocus)
                            
                            Button(action:{
                                searchState = false
                                searchProducto = ""
                            }){
                                Text("Cancelar")
                            }
                            .foregroundStyle(Color.blue)
                        }
                        .padding()
                        .padding(.top, 50)
                        .background(Material.ultraThin)
                        
                        Spacer()
                    }
                    .zIndex(20)
                }
            }
            .ignoresSafeArea()
        }
        .navigationBarTitleDisplayMode(.large)
        .navigationTitle(screenTitle)
        .toolbar(searchState ? .hidden : .visible, for: .navigationBar)
        .onAppear {
            loadProductos()
            loadCategories()
            loadInfo()
        }
    }
}
