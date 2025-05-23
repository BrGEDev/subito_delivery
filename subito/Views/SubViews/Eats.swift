//
//  Eats.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 01/10/24.
//

import AppIntents
import SwiftData
import SwiftUI

struct Eats: View {
    @ObservedObject var router = NavigationManager.shared

    @Environment(\.modelContext) var context
    @Environment(\.colorScheme) var colorScheme

    @State var isExpand: Bool = false
    @State var activeID: String = ""

    @State var searchExpand: Bool = false
    @FocusState var searchfocusable: Bool

    @StateObject var api: ApiCaller = ApiCaller()
    @StateObject var searchModel = SearchViewModel()

    @StateObject var indexModel = IndexViewModel.shared
    @State var orders: [Orders] = []
    @State var locatedEstablishment: [Establishments] = []

    @State var searchableText: Bool = false

    @State var cartModal: Bool = false
    @State var directionModal: Bool = false
    @State var seeAccount: Bool = false
    @State var path = NavigationPath()
    @State var alert: Bool = false
    @State var alertTitle: String = ""
    @State var alertMessage: String = ""

    @ObservedObject var pendingOrderModel = PendingOrderModel.shared

    @Query var userData: [UserSD]
    var user: UserSD? { userData.first }
    @Query(
        filter: #Predicate<DirectionSD> { direction in
            direction.status == true
        }) var directions: [DirectionSD]
    var directionSelected: DirectionSD? { directions.first }

    private let adaptiveColumn = [
        GridItem(.adaptive(minimum: 140))
    ]

    @StateObject var aiModel: EatsModel = EatsModel.shared

    var body: some View {
        ZStack(alignment: .top) {
            if searchableText {
                VStack {
                    ZStack {
                        HStack {
                            Image(systemName: "magnifyingglass")

                            TextField(
                                "Tacos, Pollo, Hamburguesas...",
                                text: $searchModel.searchText
                            )
                            .focused($searchfocusable)
                            .onReceive(searchModel.$searchText) { (text) in
                                withAnimation {
                                    if text.isEmpty {
                                        searchExpand = false
                                    } else {
                                        searchExpand = true
                                    }
                                }
                            }

                            Button(action: {
                                withAnimation(
                                    .spring(
                                        response: 0.5,
                                        dampingFraction: 0.9,
                                        blendDuration: 0.5
                                    )
                                ) {
                                    searchModel.searchText = ""
                                    searchableText = false
                                    searchfocusable = false
                                }
                            }) {
                                Text("Cancelar")
                                    .font(.caption)
                            }
                            .foregroundStyle(Color.primary)
                        }
                    }
                    .padding()
                    .frame(height: 50)
                    .background(
                        searchExpand
                            ? Color.white.opacity(0)
                            : Color.secondary.opacity(0.25)
                    )
                    .clipShape(.capsule)
                    .padding([.leading, .trailing])

                    if searchExpand {
                        Divider().frame(height: 2).background(Color.primary)
                            .padding([.leading, .trailing])

                        SearchItems(searchModel: searchModel)
                    }
                }
                .zIndex(20)
                .background(Material.bar)
            }

            ScrollView {

                if !searchableText {
                    HStack(alignment: .center) {
                        VStack {
                            Text("Hola, \(user?.name ?? "User")")
                                .font(.largeTitle)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .bold()
                                .multilineTextAlignment(.leading)
                                .frame(
                                    maxWidth: .infinity,
                                    alignment: .leading)

                            Text(Date.now, style: .date)
                                .font(.headline)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .foregroundStyle(.secondary)
                                .bold()
                                .multilineTextAlignment(.leading)
                                .frame(
                                    maxWidth: .infinity,
                                    alignment: .leading)
                        }

                        Spacer()

                        Button(action: {
                            seeAccount = true
                        }) {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                                .clipped()
                                .foregroundStyle(
                                    colorScheme == .dark
                                        ? .white : .black)
                        }
                        .sheet(isPresented: $seeAccount) {
                            Account()
                        }
                    }
                    .padding()

                    //                    SiriTipView(intent: SearchInSubito(), isVisible: .constant(true))
                    //                        .clipShape(.capsule)
                    //                        .padding([.leading, .trailing, .bottom])

                    Button(action: {
                        withAnimation {
                            searchableText = true
                            searchfocusable = true
                        }
                    }) {
                        Text("Buscar en Súbito Delivery")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color.gray.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity)
                    .padding([.bottom, .trailing, .leading])
                }

                LazyVStack {
                    ZStack {
                        VStack {
                            ScrollView(
                                .horizontal, showsIndicators: false
                            ) {
                                if indexModel.categories.count > 0 {
                                    HStack {
                                        ForEach(indexModel.categories) { item in
                                            Category(
                                                category: item
                                            )
                                            .padding(
                                                EdgeInsets(
                                                    top: 0, leading: 5,
                                                    bottom: 0,
                                                    trailing: 5))
                                        }
                                    }
                                } else {
                                    HStack {
                                        ForEach(0..<10) { _ in
                                            SkeletonCellView(
                                                width: 65, height: 65
                                            )
                                            .padding(
                                                EdgeInsets(
                                                    top: 0, leading: 5,
                                                    bottom: 0,
                                                    trailing: 5))
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
                                Button(action: {
                                    router.navigateTo(.Order(id: item.id_order))
                                }) {
                                    OrderCard(order: item)
                                }
                            }
                        }
                    } else {
                        NavigationLink(
                            destination: ListOrders(orders: orders)
                        ) {
                            ListOrderCard(orders: orders)
                        }
                    }
                }

                if #available(iOS 18.0, *) {
                    if aiModel.favIntelligence != nil {
                        IntelligentView(favIntelligence: aiModel.favIntelligence!)
                    }
                }

                HomePage()

                if aiModel.locatedEstablishment.count > 0 {
                    VStack {
                        VStack {
                            Text("Los más cercanos a ti")
                                .font(.title2)
                                .bold()

                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding([.top, .leading, .trailing])

                        ScrollView(.horizontal) {
                            LazyHStack(spacing: 16) {
                                ForEach(
                                    aiModel.locatedEstablishment,
                                    id: \.id_restaurant
                                ) { item in
                                    NavigationLink(
                                        destination: EstablishmentView(
                                            data: item)
                                    ) {
                                        VStack(spacing: 8) {
                                            ZStack {
                                                EstablishmentLocated(
                                                    data: item
                                                )
                                                .scrollTransition(
                                                    axis: .horizontal
                                                ) { content, phase in
                                                    return
                                                        content
                                                        .rotationEffect(
                                                            .degrees(
                                                                phase
                                                                    .value
                                                                    * 2.5
                                                            )
                                                        )
                                                        .offset(
                                                            x: phase
                                                                .value
                                                                * -250)
                                                }
                                            }
                                            .containerRelativeFrame(
                                                .horizontal
                                            )
                                            .clipShape(
                                                RoundedRectangle(
                                                    cornerRadius: 32))

                                            Text(item.name_restaurant)
                                                .frame(
                                                    width: Screen.width
                                                        * 0.55
                                                )
                                                .lineLimit(1)
                                                .truncationMode(.tail)
                                                .font(.title.bold())
                                                .foregroundStyle(
                                                    colorScheme == .dark
                                                        ? Color.white
                                                        : Color.black)
                                        }
                                    }
                                }
                            }
                            .scrollTargetLayout()
                        }
                        .contentMargins(.horizontal, 32)
                        .scrollTargetBehavior(.paging)
                    }
                }

                VStack {
                    Text("Los favoritos del momento")
                        .font(.title2)
                        .bold()

                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding([.leading, .trailing])
                .padding(.top, 20)

                LazyVGrid(columns: adaptiveColumn, spacing: 10) {

                    if indexModel.items.count > 0 {
                        ForEach(indexModel.items) { item in
                            GeometryReader { reader in
                                CardEstablishment(
                                    data: item,
                                    typeModal: .Small,
                                    isActive: $activeID,
                                    isExpand: $isExpand
                                )
                                .frame(width: isExpand ? Screen.width : Screen.width * 0.45)
                                .offset(
                                    x: activeID == item.id_restaurant
                                        ? -reader.frame(in: .global)
                                            .minX : 0,
                                    y: activeID == item.id_restaurant
                                        ? -reader.frame(in: .global)
                                            .minY : 0
                                )
                                .opacity(
                                    activeID != item.id_restaurant
                                        && isExpand
                                        ? 0 : 1)
                            }
                            .frame(width: isExpand ? Screen.width : Screen.width * 0.45, height: 200)
                        }
                    } else {
                        ForEach(0..<6) { _ in
                            SkeletonCellView(
                                width: Screen.width * 0.45, height: 200
                            )
                            .blinking(duration: 0.75)
                        }
                    }

                }
                .padding()

            }
            .scrollIndicators(.hidden)
        }
        .toolbar(
            isExpand == true || searchableText == true
                ? .hidden : .visible, for: .automatic
        )
        .toolbar(isExpand == true ? .hidden : .visible, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    directionModal = true
                }) {
                    Image(systemName: "mappin.circle")
                    Text(
                        directionSelected?.full_address
                            ?? "Seleccione su ubicación"
                    )
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: 220)
                    .foregroundStyle(
                        colorScheme == .dark ? .white : .black)
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    cartModal = true
                }) {
                    Image(systemName: "cart")
                        .foregroundStyle(.primary)
                }
            }
        }
        .alert(isPresented: $alert) {
            Alert(
                title: Text(alertTitle), message: Text(alertMessage),
                dismissButton: .default(Text("Aceptar")))
        }
        .sheet(isPresented: $pendingOrderModel.pendingModal) {
            PendingOrder()
                .presentationBackgroundInteraction(.disabled)
                .interactiveDismissDisabled(true)
        }
        .onAppear {
            isExpand = false
            activeID = ""
            loadOrders()
            if directionSelected != nil {
                aiModel.loadLocationEstablishments(directionSelected: directionSelected!)
            }
        }
        .refreshable {
            loadOrders()
            aiModel.fetchFavIntelligence()
            if !isExpand {
                indexModel.loadTypes()
                indexModel.loadPopularEstablishments()
                if directionSelected != nil {
                    aiModel.loadLocationEstablishments(directionSelected: directionSelected!)
                }
            }
        }
        .sheet(isPresented: $cartModal) {
            CartModal(
                isPresented: $cartModal)
        }
        .sheet(
            isPresented: $directionModal
        ) {
            DirectionsModal()
        }
    }

}
