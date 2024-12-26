//
//  Taxi.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 01/10/24.
//

import SwiftUI
import MapKit
import SwiftData

struct Taxi: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @State var userData: LoginInfo?
    
    @State var dragValue = CGSize.zero
    
    @StateObject var locationManager: LocationManager = .init()
    @State var coords: MapCameraPosition = .userLocation(followsHeading: true, fallback: .camera(MapCamera(centerCoordinate: .Puebla, distance: 120, pitch: 0)))
    @State var showMap: Bool = false
    
    @State var directions: Bool = false
    @State var seeAccount: Bool = false
    
    @State var isExpand: Bool = false
    @State var locatioN: String = ""
    @State var destino: String = ""
    @State var solicitar: Bool = false
    
    @Binding var selection: Int
    @State var inicioViaje: String = ""
    
    @FocusState var directionsFields: Bool
    @FocusState var toFields: Bool
    
    @State var fromDirections: Bool = false
    @State var toDirections: Bool = true
    
    // Recursos para mostrar las rutas en el mapa
    @Namespace var mapScope
    
    @StateObject var fromAddress: FromModel = .init()
    @StateObject var toAddress: ToModel = .init()
    
    @State var routeDisplay: Bool = false
    @State var route: MKRoute?
    @State var routeDestination: MKMapItem?
    @State var destination: AddressResult?
    @State var coordinatess: CLLocationCoordinate2D = .Puebla
    @State var locate: String = "Cargando..."
    @State var fromRoute: CLLocationCoordinate2D?
    @State var estimatedTime: String = ""
    @State var price: Int = 0
    
    @State var paymentPresent: Bool = false
    @Query(
        filter: #Predicate<CardSD> { card in
            card.status == true
        }) var payments: [CardSD]
    var paymentsSelected: CardSD? { payments.first }
    
    var body: some View {
        ZStack{
            VStack(alignment: .leading){
                if !isExpand {
                    if !solicitar {
                        HStack{
                            Button(action: {
                                selection = 1
                            }){
                                Image(systemName: "arrow.backward")
                                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(colorScheme == .dark ? .black : .white)
                            .buttonBorderShape(.circle)
                            .shadow(radius: 17)
                            
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
                                    .shadow(radius: 17)
                            }
                            .sheet(isPresented: $seeAccount){
                                Account()
                            }
                        }
                        .padding(.top, 50)
                    } else {
                        HStack{
                            Button(action: {
                                solicitar = false
                                isExpand = true
                                locate = "Cargando..."
                                route = nil
                                fromDirections = false
                                toDirections = true
                                directionsFields = false
                                toFields = true
                            }){
                                Image(systemName: "arrow.backward")
                                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(colorScheme == .dark ? .black : .white)
                            .buttonBorderShape(.circle)
                            .shadow(radius: 17)
                            
                            Spacer()
                            
                            VStack(alignment: .leading){
                                Text(locate)
                                    .bold()
                                    .font(.subheadline)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(10)
                            .background(Material.bar)
                            .clipShape(.capsule)
                            .clipped()
                            .shadow(radius: 17)
                        }
                        .padding(.top, 50)
                    }
                } else {
                    HStack{
                        Spacer()
                        
                        Button(action: {
                            isExpand = false
                            fromRoute = locationManager.userLocation
                        }){
                            Image(systemName: "xmark")
                                .foregroundStyle(colorScheme == .dark ? .white : .black)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(colorScheme == .dark ? .black : .white)
                        .buttonBorderShape(.circle)
                        .shadow(radius: 17)
                    }
                    .padding(.top, 50)
                }
                    
                Spacer()
            }
            .zIndex(20)
            .padding()
        
            
            if showMap {
                ZStack(alignment: .top){
                    Map(position: $coords, scope: mapScope){
                        UserAnnotation()
                        
                        if solicitar {
                            if let route {
                                Marker(locate, coordinate: coordinatess)
                                
                                MapPolyline(route.polyline)
                                    .stroke(.yellow, lineWidth: 10)
                            }
                        }
                    }
                    .mapControls{
                        MapCompass().mapControlVisibility(.hidden)
                    }
                    .ignoresSafeArea()
                    .onAppear{
                        coords = .userLocation(followsHeading: true, fallback: .camera(MapCamera(centerCoordinate: locationManager.userLocation, distance: 30)))
                    }
                    HStack{
                        Spacer()
                        
                        MapUserLocationButton(scope: mapScope)
                            .buttonBorderShape(.circle)
                            .shadow(radius: 17)
                            .frame(width: 40, height: 40)
                            .padding()
                    }
                    .padding(.top, 110)
                }
                .mapScope(mapScope)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                
                ZStack{
                    VStack{
                        ZStack{
                            Label("¿A dónde quieres ir?", systemImage: isExpand ? "" : "car.fill")
                                .font(.title3)
                                .bold()
                                .foregroundStyle(colorScheme == .dark ? .white : .black)
                                .frame(maxWidth: .infinity, maxHeight: 70)
                                .background(!isExpand ? (colorScheme == .dark ? .black.opacity(0.2) : .black.opacity(0.07)) : .white.opacity(0))
                                .clipShape(RoundedRectangle(cornerRadius: 55))
                                .padding([.leading, .trailing, .bottom])
                                .padding(.top, isExpand ? 90 : 0)
                        }
                        
                        if isExpand{
                            VStack{
                                HStack{
                                    Image(systemName: "location.fill")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .padding([.trailing, .leading], 5)
                                    
                                    TextField("Partida", text: $fromAddress.searchText)
                                        .multilineTextAlignment(.leading)
                                        .padding()
                                        .frame(height: 50)
                                        .background(.bar)
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                        .onAppear {
                                            UITextField.appearance().clearButtonMode = .whileEditing
                                        }
                                        .onReceive(
                                            fromAddress.$searchText.debounce(
                                                for: .seconds(0),
                                                scheduler: DispatchQueue.main
                                            )
                                        ) {
                                            fromAddress.searchAddress($0)
                                        }
                                        .focused($directionsFields)
                                        .onChange(of: directionsFields) { oldValue, isFocused in
                                            if isFocused {
                                                fromDirections = true
                                                toDirections = false
                                            }
                                        }
                                }
                                
                                HStack {
                                    Image(systemName: "point.topright.filled.arrow.triangle.backward.to.point.bottomleft.scurvepath")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .padding([.trailing, .leading], 5)
                                    
                                    TextField("Destino", text: $toAddress.searchText)
                                        .multilineTextAlignment(.leading)
                                        .padding()
                                        .frame(height: 50)
                                        .background(.bar)
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                        .onAppear {
                                            UITextField.appearance().clearButtonMode = .whileEditing
                                        }
                                        .onReceive(
                                            toAddress.$searchText.debounce(
                                                for: .seconds(0),
                                                scheduler: DispatchQueue.main
                                            )
                                        ) {
                                            toAddress.searchAddress($0)
                                        }
                                        .focused($toFields)
                                        .onChange(of: toFields) { oldValue, isFocused in
                                            if isFocused {
                                                fromDirections = false
                                                toDirections = true
                                            }
                                        }
                                }
                            }
                            .padding([.leading, .trailing])
                            
                            Spacer(minLength: 30)

                            // Lista de direcciones
                            
                            if toDirections {
                                if toAddress.searchText != "" {
                                    ScrollView(showsIndicators: false){
                                        VStack {
                                            ForEach(toAddress.results) { address in
                                                AddressRow(address: address)
                                                    .onTapGesture {
                                                        if fromAddress.searchText != "" {
                                                            solicitar = true
                                                            isExpand = false
                                                            destination = address
                                                            geocode(address: destination!)
                                                        } else {
                                                            directionsFields = true
                                                            toFields = false
                                                        }
                                                    }
                                            }
                                        }
                                        .padding([.leading, .trailing])
                                        .padding(.bottom, 25)
                                        .frame(maxWidth: .infinity)
                                    }
                                } else {
                                    Text("Elegir en el mapa")
                                    ScrollView(showsIndicators: false){
                                        VStack{
                                            ForEach(0..<10) { i in
                                                HStack{
                                                    Image(systemName: "clock.fill")
                                                        .frame(width: 20, height: 20)
                                                        .padding([.trailing, .leading], 5)
                                                    
                                                    VStack(alignment:.leading){
                                                        Text("Avenida Claustro de la Talavera 71")
                                                            .bold()
                                                            .font(.headline)
                                                        
                                                        Text("Geovillas Santa Clara, 72825 San Bernardino Tlaxcalancingo, Puebla, México")
                                                            .lineLimit(2)
                                                            .truncationMode(.tail)
                                                            .font(.subheadline)
                                                            .foregroundStyle(.secondary)
                                                    }
                                                }
                                                .padding([.leading, .trailing], 10)
                                                .padding([.top, .bottom])
                                                .background(colorScheme == .dark ? .black.opacity(0.35) : .white)
                                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                                .clipped()
                                                .padding(.bottom, 8)
                                                .onTapGesture {
                                                    solicitar = true
                                                    isExpand = false
                                                }
                                            }
                                        }
                                        .padding([.leading, .trailing])
                                        .padding(.bottom, 25)
                                        .frame(maxWidth: .infinity)
                                    }
                                }
                            } else if fromDirections {
                                if fromAddress.searchText != "" && fromAddress.searchText != locatioN {
                                    ScrollView(showsIndicators: false){
                                        VStack {
                                            ForEach(fromAddress.results) { address in
                                                AddressRow(address: address, type_icon: "from")
                                                    .onTapGesture {
                                                        fromAddress.searchText = address.title
                                                        geocodeFrom(address: address) { res in
                                                            fromRoute = res
                                                            
                                                            if toAddress.searchText != "" && destination != nil {
                                                                solicitar = true
                                                                isExpand = false
                                                                geocode(address: destination!)
                                                            } else {
                                                                directionsFields = false
                                                                toFields = true
                                                            }
                                                        }
                                                       
                                                    }
                                            }
                                        }
                                        .padding([.leading, .trailing])
                                        .padding(.bottom, 25)
                                        .frame(maxWidth: .infinity)
                                    }
                                } else {
                                    ScrollView(showsIndicators: false){
                                        VStack{
                                            ForEach(0..<10) { i in
                                                HStack{
                                                    Image(systemName: "location.fill")
                                                        .frame(width: 20, height: 20)
                                                        .padding([.trailing, .leading], 5)
                                                    
                                                    VStack(alignment:.leading){
                                                        Text("Avenida Claustro de la Talavera 71")
                                                            .bold()
                                                            .font(.headline)
                                                        
                                                        Text("Geovillas Santa Clara, 72825 San Bernardino Tlaxcalancingo, Puebla, México")
                                                            .lineLimit(2)
                                                            .truncationMode(.tail)
                                                            .font(.subheadline)
                                                            .foregroundStyle(.secondary)
                                                    }
                                                }
                                                .padding([.leading, .trailing], 10)
                                                .padding([.top, .bottom])
                                                .background(colorScheme == .dark ? .black.opacity(0.35) : .white)
                                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                                .clipped()
                                                .padding(.bottom, 8)
                                                .onTapGesture {
                                                    solicitar = true
                                                    isExpand = false
                                                }
                                            }
                                        }
                                        .padding([.leading, .trailing])
                                        .padding(.bottom, 25)
                                        .frame(maxWidth: .infinity)
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: isExpand ? .infinity : 105, alignment: isExpand ? .top : .bottom)
                    .background(isExpand ? .thinMaterial : .bar)
                    .clipShape(RoundedRectangle(cornerRadius: isExpand ? 30 : 55))
                    .shadow(color: Color.black.opacity(0.2), radius: 15)
                    .padding([.leading, .trailing], isExpand ? 0 : 3)
                    .onTapGesture {
                        if !isExpand {
                            getDirections(location: locationManager.coordinates)
                        }
                        
                        isExpand = true
                    }
                    .animation(Animation.spring(response: 0.5, dampingFraction: 0.9, blendDuration: 0.5))
                }
                .padding(isExpand ? EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0) : EdgeInsets(top: 0, leading: 5, bottom: 25, trailing: 5))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .sheet(isPresented: $solicitar){
                    NavigationView{
                        VStack{
                            Text("Inicio de viaje en \(inicioViaje)")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding([.leading, .trailing])
                                .padding([.top], 25)
                                .lineLimit(1)
                                .truncationMode(.tail)
                            
                            
                            VStack{
                                HStack{
                                    Image(systemName: "car.fill")
                                        .resizable()
                                        .frame(width: 25, height: 25)
                                        .padding([.leading, .trailing])
                                    
                                    VStack(alignment: .leading){
                                        Text("Súbito Go")
                                        Text("Llegada: \(estimatedTime)")
                                    }
                                    
                                    Spacer()
                                    
                                    Text(price, format: .currency(code: "MXN"))
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Material.bar)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .clipped()
                                .padding([.leading, .trailing])
                                .shadow(color: .black.opacity(0.2), radius: 10)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            
                            VStack {
                                Button(action: {paymentPresent = true}){
                                    HStack{
                                        Label(paymentsSelected == nil ? "Selecciona un método de pago" : "\(paymentsSelected!.card_type) \(paymentsSelected!.last_four)", systemImage: "creditcard.fill")
                                            .multilineTextAlignment(.leading)
                                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding([.leading, .trailing])
                                .padding(.bottom, 10)
                                .sheet(isPresented: $paymentPresent){
                                    NavigationView{
                                        PaymentMethod()
                                            .navigationBarTitleDisplayMode(.inline)
                                    }
                                }
                                
                                Button(action: {}){
                                    Text("Solicitar viaje")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .font(.system(size: 18))
                                        .bold()
                                }
                                .foregroundColor(.white)
                                .frame(height: 50)
                                .background(.accent)
                                .cornerRadius(20)
                                .shadow(color: .black.opacity(0.2), radius: 10)
                            }
                            .frame(maxWidth: .infinity)
                            .padding([.leading, .trailing])
                            .padding([.top, .bottom], 13)
                        }
                    }
                    .presentationDetents([.height(280)])
                    .presentationBackgroundInteraction(.enabled(upThrough: .height(280)))
                    .interactiveDismissDisabled(true)
                    .presentationCornerRadius(35)
                    .presentationBackground(Material.bar)
                }
            } else {
                VStack{
                    ProgressView().progressViewStyle(.circular).frame(height: 700)
                    Text("Cargando mapa...")
                }
            }
        }
        .ignoresSafeArea()
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .onChange(of: locationManager.isLocationAuthorized) { oldVal, newVal in
            if newVal {
                showMap = true
                fromRoute = locationManager.userLocation
            }
            
            loadUser()
        }
    }
}
