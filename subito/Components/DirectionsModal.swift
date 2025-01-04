//
//  DirectionsModal.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 01/10/24.
//

import SwiftUI
import MapKit
import SwiftData

struct DirectionsModal: View {
    @Environment(\.modelContext) var context
    @Query(sort: \DirectionSD.id, order: .forward) var directions: [DirectionSD]
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @Environment(\.dismissSearch) var dismissSearch
    
    @StateObject var locationManager: LocationManager = .init()
    @State var location: CLLocation = .init()
    @StateObject var DeliveryAddress: DeliveryAddress = .init()
    
    @State var address: String = ""
    @State var reload: String = ""
    
    @StateObject var api: ApiCaller = ApiCaller()
    @State var path: NavigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            List{
                Section{
                    HStack{
                        Image(systemName: "mappin")
                            .frame(width: 20, height: 20)
                            .padding([.trailing, .leading], 5)
                        
                        VStack(alignment:.leading){
                            HStack{
                                VStack(alignment: .leading){
                                    Text("Mi ubicación")
                                        .bold()
                                        .font(.headline)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing){
                                    Button(action:{
                                        getDirections(location: locationManager.coordinates)
                                    }){
                                        Text("Actualizar")
                                            .font(.system(size: 14))
                                    }
                                    .foregroundStyle(.black)
                                    .padding([.trailing, .leading], 15)
                                    .padding([.top, .bottom], 10)
                                }
                            }
                        }
                    }
                    .padding([.leading, .trailing], 10)
                    .padding([.top, .bottom])
                    .background(colorScheme == .dark ? .black.opacity(0.35) : .white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .clipped()
                }
                .listRowBackground(Color.white.opacity(0))
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .listSectionSeparator(.hidden)
                
                SearchView { isSearching in
                    Section(
                        header: Text(isSearching ? "Direcciones encontradas" : "Mis direcciones"),
                        footer: Text(!isSearching ? "Mantén presionada una dirección para editar la información." :"")
                    ){
                        if isSearching {
                            ForEach(DeliveryAddress.results) { address in
                                NavigationLink(destination: AddDirection(address: address, reload: $reload)){
                                    AddressRow(address: address)
                                }
                                .listRowInsets(EdgeInsets())
                                .listSectionSeparator(.hidden)
                            }
                        } else {
                            if directions.count == 0 {
                                Text("Aún no tienes direcciones guardadas")
                            } else {
                                ForEach(directions){ address in
                                    AddressList(address: address)
                                        .onTapGesture {
                                            updateSelected(address: address)
                                        }
                                        .contextMenu {
                                            Button {
                                                DispatchQueue.main.asyncAfter(deadline: .now()) {
                                                    if !path.isEmpty {
                                                        path.removeLast()
                                                    }
                                                    
                                                    path.append(address)
                                                }
                                            } label: {
                                                Label("Editar dirección", systemImage: "pencil")
                                            }
                                            
                                            Button {
                                                updateSelected(address: address)
                                            } label: {
                                                Label("Seleccionar esta dirección", systemImage: "mappin")
                                            }
                                            
                                            Divider()
                                            
                                            Button(role: .destructive) {
                                                drop(address: address)
                                            } label: {
                                                Label("Eliminar", systemImage: "trash")
                                            }
                                        }
                                        .listRowBackground(address.status == true ? Color.accentColor.opacity(0.5) : (colorScheme == .dark ? .black.opacity(0.35) : .white))
                                        .listRowInsets(EdgeInsets())
                                        .listSectionSeparator(.hidden)
                                }
                                .onDelete(perform: deleteDirection)
                            }
                        }
                    }
                }
                
            }
            .toolbar{
                ToolbarItem(placement: .topBarTrailing){
                    EditButton()
                }
            }
            .navigationTitle("Seleccionar dirección")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $DeliveryAddress.searchText, prompt: Text("Buscar dirección..."))
            .onReceive(
                DeliveryAddress.$searchText.debounce(
                    for: .seconds(0),
                    scheduler: DispatchQueue.main
                )
            ) {
                DeliveryAddress.searchAddress($0)
            }
            .onAppear {
                loadDirections()
            }
            .navigationDestination(for: DirectionSD.self){ view in
                EditDirection(address: view)
            }
            .onChange(of: reload) { _, value in
                if value != "" {
                    DeliveryAddress.searchText = ""
                    loadDirections(string: value)
                }
            }
        }
    }
}


struct EditDirection: View {
    @Environment(\.colorScheme) var colorScheme
    var address: DirectionSD
    
    @State var coords: MapCameraPosition = .region(MKCoordinateRegion(center: .Puebla, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)))
    @State var position: CLLocationCoordinate2D?
    @State var modalInfo: Bool = true
    
    @State private var span: MKCoordinateSpan = .init(latitudeDelta: 0.002, longitudeDelta: 0.002)
    
    var body: some View {
        ZStack{
            ZStack(alignment: .top){
                MapReader { proxy in
                    Map(position: $coords, interactionModes: .all){
                        if position != nil {
                            Annotation("", coordinate: position!) {
                                DraggablePin(coordinate: $position, proxy: proxy) { coordinate in
                                    let newRegion = MKCoordinateRegion(center: coordinate, span: span)
                                    print(coordinate)
                                    withAnimation(.smooth) {
                                        coords = .region(newRegion)
                                    }
                                }
                            }
                        }
                    }
                    .safeAreaInset(edge: .bottom){
                        VStack{
                            VStack(alignment: .leading, spacing: 10){
                                Text("Mueve el marcador a la ubicación correcta de tu domicilio. Nos ayudará a entregar tu pedido lo más pronto posible.")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                    .padding(.bottom, 10)
                                    .fixedSize(horizontal: false, vertical: true)
    
                                Text("Dirección")
                                    .font(.title3.bold())
                                
                                Text(address.full_address)
                            }
                            .multilineTextAlignment(.leading)
                            
                            Button(action: {
                                
                            }) {
                                Text("Actualizar mi dirección")
                                    .padding()
                                    .font(.system(size: 18))
                                    .bold()
                            }
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.black)
                            .frame(height: 50)
                            .background(Color.accentColor)
                            .cornerRadius(20)
                            .shadow(color: .black.opacity(0.2), radius: 10)
                            .padding([.top, .bottom], 33)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Material.bar)
                        .clipShape(
                            .rect(
                                topLeadingRadius: 35,
                                bottomLeadingRadius: 0,
                                bottomTrailingRadius: 0,
                                topTrailingRadius: 35
                            )
                        )
                    }
                    .mapControlVisibility(.hidden)
                    .onMapCameraChange(frequency: .continuous) { camera in
                        span = camera.region.span
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .ignoresSafeArea()
        }
        .navigationTitle("Editar dirección")
        .onAppear {
            cameraPosition()
        }
    }
    
    private func cameraPosition(){
        position = CLLocationCoordinate2D(latitude: Double(address.latitude)!, longitude: Double(address.longitude)!)
        coords = .region(MKCoordinateRegion(center: position!, span: span))
    }
}

struct AddDirection: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) var context
    @Environment(\.presentationMode) var presentationMode
    
    var address: AddressResult
    @State var direction: TemporalDirection?
    @Binding var reload: String
    
    @State var coords: MapCameraPosition = .region(MKCoordinateRegion(center: .Puebla, span: MKCoordinateSpan(latitudeDelta: 0.006, longitudeDelta: 0.006)))
    @State var position: CLLocationCoordinate2D?
    @State var modalInfo: Bool = true
    
    
    @StateObject var api: ApiCaller = ApiCaller()
    @State var alert: Bool = false
    
    @State private var span: MKCoordinateSpan = .init(latitudeDelta: 0.006, longitudeDelta: 0.006)
    
    var body: some View {
        ZStack{
            ZStack(alignment: .top){
                MapReader { proxy in
                    Map(position: $coords, interactionModes: .all){
                        if position != nil {
                            Annotation("", coordinate: position!) {
                                DraggablePin(coordinate: $position, proxy: proxy) { coordinate in
                                    let newRegion = MKCoordinateRegion(center: coordinate, span: span)
                                    
                                    direction!.latitude = coordinate.latitude
                                    direction!.longitude = coordinate.longitude
                                    
                                    withAnimation(.smooth) {
                                        coords = .region(newRegion)
                                    }
                                }
                            }
                        }
                    }
                    .safeAreaInset(edge: .bottom){
                        VStack{
                            VStack(alignment: .leading, spacing: 10){
                                Text("Mueve el marcador a la ubicación correcta de tu domicilio. Nos ayudará a entregar tu pedido lo más pronto posible.")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                    .padding(.bottom, 10)
                                    .fixedSize(horizontal: false, vertical: true)
    
                                Text("Dirección")
                                    .font(.title3.bold())
                                
                                Text(direction?.full_address ?? "Cargando...")
                            }
                            .multilineTextAlignment(.leading)
                            
                            Button(action: {
                                createDirection()
                            }) {
                                Text("Guardar dirección")
                                    .padding()
                                    .font(.system(size: 18))
                                    .bold()
                            }
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.black)
                            .frame(height: 50)
                            .background(Color.accentColor)
                            .cornerRadius(20)
                            .shadow(color: .black.opacity(0.2), radius: 10)
                            .padding([.top, .bottom], 33)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Material.bar)
                        .clipShape(
                            .rect(
                                topLeadingRadius: 35,
                                bottomLeadingRadius: 0,
                                bottomTrailingRadius: 0,
                                topTrailingRadius: 35
                            )
                        )
                    }
                    .mapControlVisibility(.hidden)
                    .onMapCameraChange(frequency: .continuous) { camera in
                        span = camera.region.span
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .ignoresSafeArea()
        }
        .navigationTitle("Agregar dirección")
        .onAppear {
            cameraPosition()
        }
        .alert(isPresented: $alert){
            Alert(
                title: Text("Error"),
                message: Text("Ocurrió un error al guardar la dirección, intente nuevamente."),
                dismissButton: .default(Text("Aceptar"))
            )
        }
    }
    
    private func createDirection() {
        let data: [String : Any] = [
            "full_address": direction!.full_address,
            "latitude": direction!.latitude,
            "longitude": direction!.longitude,
        ]

        let query = FetchDescriptor<UserSD>()
        let token = try? context.fetch(query).first?.token
        
        api.fetch(
            url: "address/add", method: "POST", body: data, token: token! ,
            ofType: SaveDirectionsResponse.self
        ) { response in
            if response.status == "success" {
                reload = direction!.full_address
                presentationMode.wrappedValue.dismiss()
            } else {
                alert = true
            }
        }
    }
    
    private func cameraPosition(){
        geocodeDirection(address: address) { res in
            direction = TemporalDirection(full_address: "\(address.title) \(address.subtitle)", latitude: res.latitude, longitude: res.longitude)
            
            position = CLLocationCoordinate2D(latitude: res.latitude, longitude: res.longitude)
            coords = .region(MKCoordinateRegion(center: position!, span: span))
        }
    }
    
    private func geocodeDirection(
        address: AddressResult,
        completion: @escaping (CLLocationCoordinate2D) -> Void
    ) {
        let searchRequest = MKLocalSearch.Request()
        let title = address.title
        let subTitle = address.subtitle

        searchRequest.naturalLanguageQuery =
            subTitle.contains(title)
            ? subTitle : title + ", " + subTitle

        MKLocalSearch(request: searchRequest).start { response, error in
            guard let response = response else {
                print(
                    "Error: \(error?.localizedDescription ?? "Unknown error").")
                return
            }

            for item in response.mapItems {
                completion(item.placemark.coordinate)
            }
        }
    }
}

struct DraggablePin: View {
    @Binding var coordinate: CLLocationCoordinate2D?
    var proxy: MapProxy
    var onCoordinateChange: (CLLocationCoordinate2D) -> ()
    
    @State private var isActive: Bool = false
    @State private var translation: CGSize = .zero
    
    var body: some View {
        GeometryReader{
            let geometry = $0.frame(in: .global)
            
            Image(.home)
                .resizable()
                .animation(.snappy, body: { content in
                    content
                        .scaleEffect(isActive ? 1.3 : 1, anchor: .bottom)
                })
                .frame(width: geometry.width, height: geometry.height)
                .onChange(of: isActive, initial: false) { oldval, newval in
                    let position = CGPoint(x: geometry.midX, y: geometry.midY)
                    
                    if let coordinate = proxy.convert(position, from: .global) {
                        self.coordinate = coordinate
                        translation = .zero
                        onCoordinateChange(coordinate)
                    }
                }
        }
        .frame(width: 40, height: 40)
        .contentShape(.rect)
        .offset(translation)
        .gesture(
            LongPressGesture(minimumDuration: 0.1)
                .onEnded {
                    isActive = $0
                }
                .simultaneously(with: DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if isActive {
                            translation = value.translation
                        }
                    }
                    .onEnded { value in
                        if isActive {
                            isActive = false
                        }
                    }
                )
        )
    }
}

#Preview {
    AppSwitch()
        .environmentObject(UserStateModel())
        .modelContainer(for: [
            UserSD.self, DirectionSD.self, CartSD.self, ProductsSD.self,
            CardSD.self, TrackingSD.self,
        ])
}
