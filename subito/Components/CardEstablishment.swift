//
//  CardEstablishment.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 01/11/24.
//

import SwiftUI

struct CardEstablishmentHeaderModal: View {
    @State var data: Establishments
    
    var body: some View {
        ZStack(alignment: .bottom){
            VStack{
                AsyncImage(url: URL(string: "https://dev-da-pw.mx/APPRISA/\(data.picture_establishment ?? "")")) { image in
                    image
                        .resizable()
                } placeholder: {
                    Image(.burger)
                        .resizable()
                }
                .frame(width: Screen.width * 0.9, alignment: .center)
            }
            .frame(width: Screen.width * 0.9, height: Screen.height * 0.45)
            .scaledToFill()
            .clipShape(RoundedRectangle(cornerRadius: 30))
            
            ZStack(alignment: .bottom){
                HStack {
                    VStack{
                        VStack(alignment: .leading){
                            AsyncImage(url: URL(string: "https://dev-da-pw.mx/APPRISA/\(data.picture_logo ?? "")")) { image in
                                image.resizable()
                            } placeholder: {
                                ProgressView()
                            }
                        }
                        .frame(width: 100, height: 100)
                        .scaledToFill()
                        .background(Color.white)
                        .clipShape(Circle())
                    }
                    .padding()
                        
                    Spacer()
                    
                }
                .frame(maxWidth: Screen.width, maxHeight: .infinity)
                .offset(x: 20, y: 130)
                .zIndex(10)
                
                ZStack{
                    HStack{
                        VStack{
                            VStack(alignment: .leading) {
                                Text(data.name_restaurant)
                                    .font(.system(.title2))
                            }
                            .padding(.leading, 120)
                            .padding()
                        }
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .bold()
                        .foregroundStyle(.white)
                        .shadow(color: .black, radius: 3)
                        
                        Spacer()
                    }
                    .frame(width: Screen.width * 0.9, alignment: .center)
                    .background(.ultraThinMaterial)
                    .clipShape(.rect(bottomLeadingRadius: 30, bottomTrailingRadius: 30))
                }
            }
        }
        .shadow(color: Color.black.opacity(0.3), radius: 5)
    }
}

struct BodyEstablishmentModal: View {
    @Binding var isExpand: Bool
    @State var data: Establishments
    @State var productosC: [ProductCategory]
    
    var body: some View {
        VStack{
            ZStack(alignment: .top){
                ZStack(alignment: .bottom){
                    VStack {
                        AsyncImage(url: URL(string: "https://dev-da-pw.mx/APPRISA/\(data.picture_establishment ?? "")")) { image in
                            image
                                .resizable()
                        } placeholder: {
                            Image(.burger)
                                .resizable()
                        }
                    }
                    .scaledToFill()
                    .frame(height: Screen.height * 0.45)
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
                    }
                    .padding(.top,100)
                    .padding(.leading, 20)
                    
                    Spacer()
                }
                .frame(maxWidth: Screen.width)
                
            }
        }
        .frame(maxWidth: Screen.width)
    }
}

struct ProductList: View {
    @Environment(\.colorScheme) var colorScheme

    @State var data: Product
    @State var location: [String:Any]
    @State var modal: Bool = false
    
    var body: some View {
        ZStack{
            Color.gray.opacity(0.05).edgesIgnoringSafeArea(.all)
            
            HStack{
                VStack(spacing: 8){
                    Text(data.pd_name)
                        .font(.title2)
                        .bold()
                        .frame(maxWidth: 200, alignment: .leading)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    Text(data.pd_description)
                        .frame(maxWidth: 200, alignment: .leading)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .truncationMode(.tail)
                    
                    Text(Float(data.pd_unit_price)!, format: .currency(code: "MXN"))
                        .frame(maxWidth: 200, alignment: .leading)
                        .bold()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                ZStack{
                    HStack{
                        Image(systemName: "plus")
                            .padding(5)
                            .background(colorScheme == .light ? Color.white : Color.black)
                            .clipShape(Circle())
                    }
                    .zIndex(2)
                    .offset(x: 30, y: 30)
                    
                    VStack {
                        AsyncImage(url: URL(string: data.pd_image ?? "")){ image in
                            image
                                .resizable()
                        } placeholder: {
                            ProgressView()
                        }
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .onTapGesture{
            modal = true
        }
        .sheet(isPresented: $modal) {
            ModalProducto(location: location, data: data)
        }
        .contextMenu {
            Button(action: {
                modal = true
            }){
                Label("Ver producto", systemImage: "eye")
            }
            
            Button(action: {}){
                Label("Agregar producto", systemImage: "plus")
            }
        } preview: {
            PreviewProduct(data: data)
        }
    }
}

struct CardEstablishment: View {
    @Environment(\.colorScheme) var colorScheme
    @State var dragValue = CGSize.zero
    
    @StateObject var api: ApiCaller = ApiCaller()
    
    @State var productos: [Product] = []
    @State var productosC: [ProductCategory] = []
    
    @State var data: Establishments
    @FocusState var searchFocus: Bool
    @State var searchState: Bool = false
    @State var searchProducto: String = ""
    @State var menuSelected: String = "Todos"
    
    @Binding var isActive: String
    @Binding var isExpand: Bool
    
    @State var categorySelect: Int = 0
    
    var body: some View {
        ZStack(alignment:.top){
            CardEstablishmentHeaderModal(data: data)
                .onTapGesture {
                    isExpand = true
                    isActive = data.id_restaurant
                    
                    loadProductos()
                    loadCategories()
                }
                .opacity(isActive == data.id_restaurant ? 0 : 1)
            
            
            ZStack{
                colorScheme == .light ? Color.white.edgesIgnoringSafeArea(.all) : Color.black.edgesIgnoringSafeArea(.all)
                
                ScrollView(.vertical, showsIndicators: false){
                    
                    VStack(spacing: 5){
                        if !searchState {
                            BodyEstablishmentModal(isExpand: $isExpand, data: data, productosC: productosC)
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
                                            ProductList(data: producto, location: ["latitude": data.latitude, "longitude": data.longitude])
                                        } else if categorySelect == 0{
                                            ProductList(data: producto, location: ["latitude": data.latitude, "longitude": data.longitude])
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
                    }
                    .padding(.bottom)
                }
                .edgesIgnoringSafeArea(.all)
                
                if !searchState {
                    VStack{
                        HStack{
                            Spacer()
                            
                            Button(action: {
                                isExpand = false
                                isActive = ""
                                searchState = false
                            }){
                                Image(systemName: "xmark")
                                    .foregroundStyle(Color.black)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.white)
                            .buttonBorderShape(.circle)
                            .shadow(radius: 17)
                        }
                        .padding(.top, 50)
                        
                        Spacer()
                    }
                    .padding()
                } else{
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
            .opacity(isActive == data.id_restaurant ? 1 : 0)
            .gesture(
                isActive == data.id_restaurant ?
                DragGesture().onChanged({ value in
                    guard value.translation.height < 200 else { return }
                    if value.translation.height > 400 {
                        isExpand = false
                        isActive = ""
                        searchState = false
                    } else {
                        dragValue = value.translation
                    }
                })
                .onEnded({value in
                    if value.translation.height > 300 {
                        isExpand = false
                        isActive = ""
                        searchState = false
                    }
                    
                    dragValue = .zero
                }) : nil
            )
            .clipShape(RoundedRectangle(cornerRadius: dragValue.height > 0 ? 50 : 0))
            .scaleEffect(1 - (dragValue.height/1000))
        }
        .frame(width: Screen.width, height: isActive == data.id_restaurant ? Screen.height : Screen.height * 0.45)
        .animation(Animation.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.6))
        .edgesIgnoringSafeArea(.all)
        .background(isExpand ? AnyShapeStyle(.thinMaterial) : AnyShapeStyle(.clear))
        .shadow(color: .black.opacity(0.25), radius: isExpand ? 5 : 0)
    }
}
