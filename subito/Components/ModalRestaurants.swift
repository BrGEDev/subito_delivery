//
//  ModalRestaurants.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 31/10/24.
//

import SwiftUI

struct Item: Identifiable{
    var id = UUID()
    var id_restaurant: String
    var title: String
    var image: String
    var establishment: String
    var address: String
    var latitude: String
    var longitude: String
}

struct HeaderModal: View {
    @State var image: String
    @State var title: String
    
    var body: some View {
        ZStack(alignment: .bottom){
            AsyncImage(url: URL(string: "https://dev-da-pw.mx/APPRISA/\(image)")) { image in
                image.resizable()
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                    .frame(height: 200)
            } placeholder: {
                ProgressView()
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                    .frame(height: 200)
            }
            
            HStack{
                VStack(alignment: .leading){
                    Text(title)
                        .font(.system(.title2))
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .bold()
                        .foregroundStyle(.white)
                        .shadow(color: .black, radius: 3)
                }
                .padding()
                
                Spacer()
            }
            .background(.ultraThinMaterial)
            .cornerRadius(30)
        }
    }
}

struct BodyModal: View {
    @Binding var isExpand: Bool
    @State var data: Item
    
    //@State var productos: [ModelCategories] = []
    
    var body: some View {
        VStack{
            ZStack(alignment: .top){
                ZStack(alignment: .bottom){
                    VStack{
                        AsyncImage(url: URL(string: "https://dev-da-pw.mx/APPRISA/\(data.establishment)")) { image in
                            image
                                .resizable()
                        } placeholder: {
                            ProgressView()
                        }
                    }
                    .scaledToFill()
                    .frame(width: isExpand ? Screen.width : Screen.width * 0.4, height: Screen.height * 0.45)
                    .brightness(-0.3)
                    
                    HStack{
                        VStack{
                            VStack(alignment: .center){
                                AsyncImage(url: URL(string: "https://dev-da-pw.mx/APPRISA/\(data.image)")) { image in
                                    image.resizable()
                                } placeholder: {
                                    ProgressView()
                                        .scaledToFill()
                                }
                            }
                            .scaledToFill()
                            .background(Color.white)
                            .clipShape(Circle())
                            .frame(width: 120, height: 120)
                            .shadow(color: .black.opacity(0.2), radius: 15)
                        }
                        .frame(maxWidth: .infinity)
                        
                        Spacer()
                    }
                    .offset(y: 15)
                }
                
                HStack{
                    VStack(alignment: .leading){
                        Text(data.title)
                            .font(.system(.largeTitle))
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .bold()
                            .foregroundStyle(.white)
                    }
                    .padding(.top, 100)
                    .padding(.leading, 20)
                    
                    Spacer()
                }
                
            }
        }
    }
}

struct ProductListF: View {
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
                    
                    AsyncImage(url: URL(string: data.pd_image ?? "")){ image in
                        image
                            .resizable()
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                    } placeholder: {
                        ProgressView()
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                    }
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
    }
}

struct ModalRestaurants: View {
    @Environment(\.colorScheme) var colorScheme
    @State var dragValue = CGSize.zero
    
    @Binding var isExpand: Bool
    @Binding var isActive: UUID
    
    @StateObject var api: ApiCaller = ApiCaller()
    @State var productos: [Product] = []
    @State var productosC: [ProductCategory] = []
    
    @FocusState var searchFocus: Bool
    @State var searchState: Bool = false
    @State var searchProducto: String = ""
    @State var menuSelected: String = "Todos"
    
    @State var categorySelect: Int = 0
    

    var data: Item
    
    func getOffsetY(basedOn geo: GeometryProxy) -> CGFloat {

            let minY = geo.frame(in: .global).minY
            
            let emptySpaceAboveSheet: CGFloat = -100
            if minY <= emptySpaceAboveSheet {
                return 0
            }
            return -minY + emptySpaceAboveSheet
    }
    
    var body: some View {
        ZStack(alignment:.top){
            HeaderModal(image: data.image, title: data.title)
            .onTapGesture {
                isExpand = true
                isActive = data.id
                
                loadProductos()
                loadCategories()
            }
            .opacity(isActive == data.id ? 0 : 1)
            
            ZStack{
                colorScheme == .light ? Color.white.edgesIgnoringSafeArea(.all) : Color.black.edgesIgnoringSafeArea(.all)
                
                ScrollView(.vertical){
                    VStack(spacing: 10){
                        if !searchState {
                            BodyModal(isExpand: $isExpand, data: data)
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
                                            ProductListF(data: producto, location: ["latitude": data.latitude, "longitude": data.longitude])
                                        } else if categorySelect == 0{
                                            ProductListF(data: producto, location: ["latitude": data.latitude, "longitude": data.longitude])
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
                                isActive = UUID()
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
                            
                            TextField("Buscar en \(data.title)", text: $searchProducto)
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
            .opacity(isActive == data.id ? 1 : 0)
            .gesture(
                isActive == data.id ?
                    DragGesture().onChanged({ value in
                        guard value.translation.height < 300 else { return }
                        if value.translation.height > 500 {
                            isExpand = false
                            isActive = UUID()
                        } else {
                            dragValue = value.translation
                        }
                    })
                    .onEnded({value in
                        if value.translation.height > 300 {
                            isExpand = false
                            isActive = UUID()
                        }
                        
                        dragValue = .zero
                    }) : nil
            )
            .clipShape(RoundedRectangle(cornerRadius: 50))
            .scaleEffect(1 - (dragValue.height/1700))
        }
    
        .frame(width: isActive == data.id ? Screen.width : 200, height: isActive == data.id ? Screen.height : 200)
        .animation(Animation.spring(response: 0.5, dampingFraction: 0.9, blendDuration: 0.5))
        .edgesIgnoringSafeArea(.all)
        .background(isExpand ? AnyShapeStyle(.thinMaterial) : AnyShapeStyle(.clear))
        .shadow(color: .black.opacity(0.25), radius: isExpand ? 5 : 0)
    }

}

