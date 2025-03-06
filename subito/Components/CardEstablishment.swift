//
//  CardEstablishment.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 01/11/24.
//

import SwiftUI
import SwiftData

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

enum StateEstablishment {
    case open
    case closed
}

enum TypeModal {
    case Large
    case Small
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

struct CardEstablishmentHeaderModal: View {
    var data: Item
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

                    }
                }
                .frame(width: Screen.width * 0.9, height: Screen.height * 0.45)
                .zIndex(20)
            }

            VStack {
                AsyncImageCache(
                    url: URL(
                        string:
                            "https://da-pw.mx/APPRISA/\(data.establishment)"
                    )
                ) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                        .clipped()
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
                            width: Screen.width * 0.9,
                            height: Screen.height * 0.45
                        )
                        .blinking(duration: 0.75)
                    }
                }
                .frame(
                    width: Screen.width * 0.9, height: Screen.height * 0.45,
                    alignment: .center)
            }
            .frame(width: Screen.width * 0.9, height: Screen.height * 0.45)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .clipped()

            ZStack(alignment: .bottom) {
                HStack {
                    VStack {
                        VStack(alignment: .leading) {
                            AsyncImageCache(
                                url: URL(
                                    string:
                                        "https://da-pw.mx/APPRISA/\(data.image)"
                                )
                            ) { image in
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

                ZStack {
                    HStack {
                        VStack {
                            VStack(alignment: .leading) {
                                Text(data.title)
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
                    .clipShape(
                        .rect(bottomLeadingRadius: 30, bottomTrailingRadius: 30)
                    )
                }
            }
        }
        .shadow(color: Color.black.opacity(0.3), radius: 5)
    }
}

struct BodyEstablishmentModal: View {
    @Binding var isExpand: Bool
    @State var data: Item
    @State var productosC: [ProductCategory]
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
                                    width: Screen.width,
                                    height: Screen.height * 0.45
                                )
                                .blinking(duration: 0.75)
                            }

                        }
                    }
                    .scaledToFill()
                    .frame(height: Screen.height * 0.45)
                    .clipped()
                    .brightness(-0.3)

                    HStack {
                        VStack(alignment: .center) {
                            VStack {
                                AsyncImageCache(
                                    url: URL(
                                        string:
                                            "https://da-pw.mx/APPRISA/\(data.image)"
                                    )
                                ) { image in
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
                .frame(maxWidth: Screen.width)

            }
        }
        .frame(maxWidth: Screen.width)
    }
}

struct ProductList: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) var modelContext
    @StateObject var api = ApiCaller()

    @State var data: Product
    @State var location: [String: Any]
    @State var modal: Bool = false

    @State var advertencia: Bool = false

    @Binding var estado: StateEstablishment

    var body: some View {
        ZStack {
            Color.gray.opacity(0.05).edgesIgnoringSafeArea(.all)

            HStack {
                VStack(spacing: 8) {
                    Text(data.pd_name)
                        .font(.title2.bold())
                        .frame(maxWidth: 200, alignment: .leading)
                        .lineLimit(1)
                        .truncationMode(.tail)

                    Text(data.pd_description ?? data.pd_name)
                        .frame(maxWidth: 200, alignment: .leading)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .truncationMode(.tail)

                    Text(
                        Float(data.pd_unit_price)!,
                        format: .currency(code: "MXN")
                    )
                    .frame(maxWidth: 200, alignment: .leading)
                    .bold()
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                ZStack {
                    HStack {
                        Image(systemName: "plus")
                            .padding(5)
                            .background(
                                colorScheme == .light
                                    ? Color.white : Color.black
                            )
                            .clipShape(Circle())
                    }
                    .zIndex(2)
                    .offset(x: 30, y: 30)

                    ZStack {
                        if estado == .closed {
                            Color.black.opacity(0.55).cornerRadius(25)
                                .zIndex(20)
                            Text("No disponible")
                                .foregroundStyle(.white)
                                .font(.footnote)
                                .zIndex(20)
                        }

                        AsyncImageCache(url: URL(string: data.pd_image ?? "")) {
                            image in
                            image
                                .resizable()
                        } placeholder: {
                            ProgressView()
                        }
                    }
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .onTapGesture {
            if estado == .open {
                modal = true
            }
        }
        .sheet(isPresented: $modal) {
            ModalProducto(location: location, data: data)
        }
        .alert(isPresented: $advertencia) {
            Alert(
                title: Text("Advertencia"),
                message: Text(
                    "Tienes productos de otro establecimiento, ¿deseas eliminar los productos anteriores y agregar los nuevos?"
                ),
                primaryButton: .default(Text("Agregar nuevos")) {
                    saveanyway(
                        api: api, context: modelContext, data: data,
                        location: location
                    ) { result in

                    }
                }, secondaryButton: .destructive(Text("Cancelar")))
        }
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 20))
        .contextMenu {
            Button(action: {
                modal = true
            }) {
                Label("Ver producto", systemImage: "eye")
            }
            .disabled(estado == .open ? false : true)

            Button(action: {
                saveproduct(
                    context: modelContext, data: data, location: location,
                    api: api
                ) { result in
                    if result == false {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            advertencia = true
                        }
                    }
                }
            }) {
                Label("Agregar producto", systemImage: "plus")
            }
            .disabled(estado == .open ? false : true)

        } preview: {
            PreviewProduct(data: data)
        }
        .zIndex(20)
    }
}

struct CardEstablishment: View {
    @Environment(\.modelContext) var context
    @ObservedObject var pendingOrderModel = PendingOrderModel.shared

    @State var data: Item
    var typeModal: TypeModal

    @Environment(\.colorScheme) var colorScheme
    @State var dragValue = CGSize.zero

    @StateObject var api: ApiCaller = ApiCaller()

    @State var productos: [Product] = []
    @State var productosC: [ProductCategory] = []
    @FocusState var searchFocus: Bool
    @State var searchState: Bool = false
    @State var searchProducto: String = ""
    @State var menuSelected: String = "Todos"

    @Binding var isActive: String
    @Binding var isExpand: Bool

    @State var categorySelect: Int = 0
    @State var estado: StateEstablishment = .closed
    @State var apertura: String = ""
    @State var cierre: String = ""
    
    @State var cartModal: Bool = false

    @State var loading: Bool = true
    
    @Query var carts: [CartSD]
    var cart: CartSD? { carts.first }

    var body: some View {
        ZStack(alignment: .top) {
            switch typeModal {
            case .Large:
                CardEstablishmentHeaderModal(
                    data: data, estado: $estado, apertura: apertura
                )
                .onTapGesture {
                    isExpand = true
                    isActive = data.id_restaurant

                    loadProductos()
                    loadCategories()
                }
                .opacity(isActive == data.id_restaurant ? 0 : 1)
            case .Small:
                HeaderModal(
                    image: data.image, title: data.title, estado: $estado,
                    apertura: apertura
                )
                .onTapGesture {
                    isExpand = true
                    isActive = data.id_restaurant

                    loadProductos()
                    loadCategories()
                }
                .opacity(isActive == data.id_restaurant ? 0 : 1)
            }

            ZStack {
                colorScheme == .light
                    ? Color.white.edgesIgnoringSafeArea(.all)
                    : Color.black.edgesIgnoringSafeArea(.all)
                
                if cart?.id == Int(data.id_restaurant) {
                    ZStack(alignment: .bottomTrailing) {
                        Button(action: {
                            cartModal = true
                        }){
                            Label {
                                Text("Ir a mi carrito")
                                    .foregroundColor(.black)
                            } icon: {
                                Image(systemName: "cart.fill")
                                    .tint(.black)
                            }
                        }
                        .padding()
                        .background(Color.accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .clipped()
                        .shadow(color: Color.black.opacity(0.2), radius: 8)
                        .padding(.bottom)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .zIndex(20)
                }

                ScrollView(.vertical, showsIndicators: false) {

                    VStack(spacing: 5) {
                        if !searchState {
                            BodyEstablishmentModal(
                                isExpand: $isExpand, data: data,
                                productosC: productosC, estado: $estado,
                                apertura: apertura, cierre: cierre)
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
                                if loading {
                                    VStack {
                                        ProgressView {
                                            Text("Cargando productos...")
                                        }
                                    }
                                } else {
                                    if filteredLocales.count != 0 {
                                        ForEach(filteredLocales, id: \.pd_id) {
                                            producto in
                                            if categorySelect == producto.pg_id
                                            {
                                                ProductList(
                                                    data: producto,
                                                    location: [
                                                        "latitude": data
                                                            .latitude,
                                                        "longitude": data
                                                            .longitude,
                                                    ], estado: $estado
                                                )
                                            } else if categorySelect == 0 {
                                                ProductList(
                                                    data: producto,
                                                    location: [
                                                        "latitude": data
                                                            .latitude,
                                                        "longitude": data
                                                            .longitude,
                                                    ], estado: $estado)
                                            }
                                        }
                                    } else {
                                        Text("No hay productos disponibles")
                                    }
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
                                isActive = ""
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
                                "Buscar en \(data.title)",
                                text: $searchProducto
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
            .opacity(isActive == data.id_restaurant ? 1 : 0)
            .gesture(
                isActive == data.id_restaurant
                    ? DragGesture().onChanged({ value in
                        guard value.translation.height < 200 else { return }
                        if value.translation.height > 400 {
                            isExpand = false
                            isActive = ""
                            searchState = false
                        } else {
                            dragValue = value.translation
                        }
                    })
                    .onEnded({ value in
                        if value.translation.height > 300 {
                            isExpand = false
                            isActive = ""
                            searchState = false
                        }

                        dragValue = .zero
                    }) : nil
            )
            .clipShape(
                RoundedRectangle(cornerRadius: dragValue.height > 0 ? 50 : 0)
            )
            .scaleEffect(1 - (dragValue.height / 1000))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            loadInfo()
        }
        .frame(
            width: typeModal == .Large
                ? Screen.width
                : (isActive == data.id_restaurant
                    ? Screen.width : Screen.width * 0.45),
            height: isActive == data.id_restaurant
                ? Screen.height
                : typeModal == .Large ? Screen.height * 0.45 : 200
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
        .background(
            isExpand ? AnyShapeStyle(.thinMaterial) : AnyShapeStyle(.clear)
        )
        .sheet(isPresented: $pendingOrderModel.pendingModal) {
            PendingOrder()
                .presentationBackgroundInteraction(.disabled)
                .interactiveDismissDisabled(true)
        }
        .shadow(color: .black.opacity(0.25), radius: isExpand ? 5 : 0)
        .sheet(isPresented: $cartModal) {
            CartModal(
                isPresented: $cartModal)
        }
    }
}
