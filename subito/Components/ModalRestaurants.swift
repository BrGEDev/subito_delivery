//
//  ModalRestaurants.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 31/10/24.
//

import SwiftUI

struct Item: Identifiable {
    var id = UUID()
    var id_restaurant: String
    var title: String
    var image: String
    var establishment: String
    var address: String
    var latitude: String
    var longitude: String
    var apertura: String
    var cierre: String
}

struct HeaderModal: View {
    @State var image: String
    @State var title: String

    @Binding var estado: StateEstablishment
    var apertura: String = ""

    var body: some View {
        ZStack(alignment: .bottom) {
            if estado == .closed {
                VStack {
                    ZStack {
                        Color.black.opacity(0.55).cornerRadius(30)

                        Text("Cerrado hasta \(apertura)")
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                }
                .frame(width: Screen.width * 0.45, height: 200)
                .zIndex(20)
            }

            AsyncImageCache(
                url: URL(string: "https://da-pw.mx/APPRISA/\(image)")
            ) { image in
                image.resizable()
                    .scaledToFill()
                    .frame(width: Screen.width * 0.45, height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                    .clipped()
            } placeholder: {
                SkeletonCellView(
                    width: Screen.width * 0.45, height: 200
                )
                .blinking(duration: 0.75)
            }

            HStack {
                VStack(alignment: .leading) {
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
            .frame(width: Screen.width * 0.45)
        }
    }
}

struct BodyModal: View {
    @Binding var isExpand: Bool
    @State var data: Item

    @Binding var estado: StateEstablishment
    var apertura: String = ""
    var cierre: String = ""

    var body: some View {
        VStack {
            ZStack(alignment: .top) {
                ZStack(alignment: .bottom) {
                    VStack {
                        AsyncImageCache(
                            url: URL(
                                string:
                                    "https://da-pw.mx/APPRISA/\(data.establishment)"
                            )
                        ) { image in
                            image
                                .resizable()
                        } placeholder: {
                            AsyncImageCache(
                                url: URL(
                                    string:
                                        "https://da-pw.mx/APPRISA/\(data.image)"
                                )
                            ) { image in
                                image
                                    .resizable()
                            } placeholder: {
                                SkeletonCellView(
                                    width: isExpand
                                        ? Screen.width : Screen.width * 0.4,
                                    height: Screen.height * 0.45
                                )
                                .blinking(duration: 0.75)
                            }
                        }
                    }
                    .scaledToFill()
                    .frame(
                        width: isExpand ? Screen.width : Screen.width * 0.4,
                        height: Screen.height * 0.45
                    )
                    .clipped()
                    .brightness(-0.3)

                    HStack {
                        VStack {
                            VStack(alignment: .center) {
                                AsyncImageCache(
                                    url: URL(
                                        string:
                                            "https://da-pw.mx/APPRISA/\(data.image)"
                                    )
                                ) { image in
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

                HStack {
                    VStack(alignment: .leading) {
                        Text(data.title)
                            .font(.system(.largeTitle))
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .bold()
                            .foregroundStyle(.white)

                        if estado == .closed {
                            Text("Cerrado hasta \(apertura)")
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.top, 100)
                    .padding(.leading, 20)

                    Spacer()
                }

            }
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
    @State var estado: StateEstablishment = .closed
    @State var apertura: String = ""
    @State var cierre: String = ""

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
        ZStack(alignment: .top) {
            HeaderModal(
                image: data.image, title: data.title, estado: $estado,
                apertura: apertura
            )
            .onTapGesture {
                isExpand = true
                isActive = data.id

                loadProductos()
                loadCategories()
            }
            .opacity(isActive == data.id ? 0 : 1)

            ZStack {
                colorScheme == .light
                    ? Color.white.edgesIgnoringSafeArea(.all)
                    : Color.black.edgesIgnoringSafeArea(.all)

                ScrollView(.vertical) {
                    VStack(spacing: 10) {
                        if !searchState {
                            BodyModal(
                                isExpand: $isExpand, data: data,
                                estado: $estado, apertura: apertura,
                                cierre: cierre)
                        }

                        Spacer()

                        VStack(spacing: 20) {
                            if searchState {
                                Spacer(minLength: 95)
                            }

                            if !searchState {
                                HStack {
                                    HStack {
                                        Text(menuSelected)
                                            .bold()
                                            .multilineTextAlignment(.leading)
                                            .font(.title2)
                                            .frame(
                                                maxWidth: .infinity,
                                                alignment: .leading)

                                        Button(action: {
                                            searchState.toggle()
                                        }) {
                                            Image(systemName: "magnifyingglass")
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                        }
                                        .frame(
                                            maxWidth: .infinity,
                                            alignment: .trailing)
                                    }
                                }
                            }

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    VStack {
                                        Text("Todos")
                                            .padding(
                                                EdgeInsets(
                                                    top: 10, leading: 20,
                                                    bottom: 10, trailing: 20))
                                    }
                                    .background(
                                        categorySelect == 0
                                            ? AnyShapeStyle(
                                                Color.accentColor.opacity(0.4))
                                            : AnyShapeStyle(Material.ultraThin)
                                    )
                                    .clipShape(.capsule)
                                    .onTapGesture {
                                        menuSelected = "Todos"
                                        categorySelect = 0
                                    }

                                    ForEach(productosC, id: \.pg_id) { item in
                                        VStack {
                                            Text(item.pg_name)
                                                .padding(
                                                    EdgeInsets(
                                                        top: 10, leading: 20,
                                                        bottom: 10, trailing: 20
                                                    ))
                                        }
                                        .background(
                                            categorySelect == item.pg_id
                                                ? AnyShapeStyle(
                                                    Color.accentColor.opacity(
                                                        0.4))
                                                : AnyShapeStyle(
                                                    Material.ultraThin)
                                        )
                                        .clipShape(.capsule)
                                        .onTapGesture {
                                            menuSelected = item.pg_name
                                            categorySelect = item.pg_id
                                        }
                                    }
                                }
                            }
                            .onTapGesture {
                                if searchFocus {
                                    searchFocus = false
                                }
                            }

                            LazyVStack(spacing: 20) {
                                if filteredLocales.count != 0 {
                                    ForEach(filteredLocales, id: \.pd_id) {
                                        producto in
                                        if categorySelect == producto.pg_id {
                                            ProductList(
                                                data: producto,
                                                location: [
                                                    "latitude": data.latitude,
                                                    "longitude": data.longitude,
                                                ], estado: $estado)
                                        } else if categorySelect == 0 {
                                            ProductList(
                                                data: producto,
                                                location: [
                                                    "latitude": data.latitude,
                                                    "longitude": data.longitude,
                                                ], estado: $estado)
                                        }
                                    }
                                } else {
                                    Text("No hay productos disponibles")
                                }
                            }
                            .onTapGesture {
                                if searchFocus {
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
                    VStack {
                        HStack {
                            Spacer()

                            Button(action: {
                                isExpand = false
                                isActive = UUID()
                                searchState = false
                            }) {
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
                } else {
                    VStack {
                        HStack {

                            TextField(
                                "Buscar en \(data.title)", text: $searchProducto
                            )
                            .padding()
                            .frame(height: 50)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .focused($searchFocus)

                            Button(action: {
                                searchState = false
                                searchProducto = ""
                            }) {
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
                isActive == data.id
                    ? DragGesture().onChanged({ value in
                        guard value.translation.height < 300 else { return }
                        if value.translation.height > 500 {
                            isExpand = false
                            isActive = UUID()
                        } else {
                            dragValue = value.translation
                        }
                    })
                    .onEnded({ value in
                        if value.translation.height > 300 {
                            isExpand = false
                            isActive = UUID()
                        }

                        dragValue = .zero
                    }) : nil
            )
            .clipShape(
                RoundedRectangle(cornerRadius: dragValue.height > 0 ? 50 : 0)
            )
            .scaleEffect(1 - (dragValue.height / 1700))
            .frame(width: isActive == data.id ? Screen.width : 200)
        }
        .onAppear {
            loadInfo()
        }
        .frame(
            width: isActive == data.id ? Screen.width : Screen.width * 0.45,
            height: isActive == data.id ? Screen.height : 200
        )
        .animation(
            Animation.spring(
                response: 0.5, dampingFraction: 0.8, blendDuration: 0.6),
            value: isExpand
        )
        .animation(
            Animation.spring(
                response: 0.5, dampingFraction: 0.8, blendDuration: 0.6),
            value: searchState
        )
        .animation(
            Animation.spring(
                response: 0.5, dampingFraction: 0.8, blendDuration: 0.6),
            value: dragValue
        )
        .edgesIgnoringSafeArea(.all)
        .edgesIgnoringSafeArea(.all)
        .background(
            isExpand ? AnyShapeStyle(.thinMaterial) : AnyShapeStyle(.clear)
        )
        .shadow(color: .black.opacity(0.25), radius: isExpand ? 5 : 1)
    }
}
