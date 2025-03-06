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
    
    @StateObject var locationManager: LocationManager = LocationManager.shared
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
                                        locationManager.requestLocation()
                                    }){
                                        Text("Actualizar")
                                            .font(.system(size: 14))
                                    }
                                    .foregroundStyle(.black)
                                    .padding([.trailing, .leading], 15)
                                    .padding([.top, .bottom], 10)
                                    .onReceive(locationManager.$coords) { val in
                                        if val != nil {
                                            getDirections(coords: val!)
                                        }
                                    }
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
                                NavigationLink(destination: OptionDirection(options: .addDirection(address: address), reload: $reload)){
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
                                            if address.id != 0 {
                                                updateSelected(address: address)
                                            } else {
                                                if !path.isEmpty {
                                                    path.removeLast()
                                                }
                                                
                                                path.append(address)
                                            }
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
                                            
                                            if address.id != 0 {
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
                OptionDirection(options: .editDirection(address: view), reload: $reload)
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


struct OptionDirection: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) var context
    @Environment(\.presentationMode) var presentationMode
    
    var options: DirectionsOptions
    @State var direction: TemporalDirection?
    @Binding var reload: String
    
    @State var title = "Agregar dirección"
    @State var coords: MapCameraPosition = .region(MKCoordinateRegion(center: .Puebla, span: MKCoordinateSpan(latitudeDelta: 0.006, longitudeDelta: 0.006)))
    @State var position: CLLocationCoordinate2D?
    @State var modalInfo: Bool = true
    
    
    @StateObject var api: ApiCaller = ApiCaller()
    @State var alert: Bool = false
    
    @State private var span: MKCoordinateSpan = .init(latitudeDelta: 0.006, longitudeDelta: 0.006)
    
    @State var name_direction: String = ""
    @State var references: String = ""
    @State var modal: Bool = true
    
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
                        ZStack{}
                            .frame(maxHeight: Screen.height / 2)
                            .sheet(isPresented: $modal){
                                VStack{
                                    VStack{
                                        ScrollView{
                                            VStack(alignment: .leading, spacing: 10){
                                                Text("Dirección")
                                                    .font(.title3.bold())
                                                
                                                Text(direction?.full_address ?? "Cargando...")
                                                    .padding(.bottom)
                                                
                                                TextField("Nombre de dirección. Ejemplo: 'Casa', 'Oficina'", text: $name_direction)
                                                    .padding()
                                                    .background(.ultraThinMaterial)
                                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                                
                                                TextField("Referencias", text: $references)
                                                    .padding()
                                                    .background(.ultraThinMaterial)
                                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                                
                                                Text("Mueve el marcador a la ubicación correcta de tu domicilio. Nos ayudará a entregar tu pedido lo más pronto posible.")
                                                    .font(.footnote)
                                                    .fixedSize(horizontal: false, vertical: true)
                                                    .shadow(radius: 0.5)
                                                    .zIndex(20)
                                            }
                                            .padding()
                                            .multilineTextAlignment(.leading)
                                        }
                                        .padding([.bottom, .top], 10)
                                        
                                        VStack{
                                            Button(action: {
                                                saveDirection()
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
                                        }
                                        .padding([.trailing, .leading])
                                    }
                                }
                                .presentationDetents([.fraction(0.52)])
                                .presentationBackgroundInteraction(.enabled)
                                .presentationDragIndicator(.hidden)
                                .interactiveDismissDisabled(true)
                                .presentationBackground(Material.bar)
                                .presentationCornerRadius(35)
                            }
                    }
                    .mapControlVisibility(.hidden)
                    .onMapCameraChange(frequency: .continuous) { camera in
                        span = camera.region.span
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .top)
            .ignoresSafeArea(.all, edges: .bottom)
        }
        .navigationTitle(title)
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
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading){
                Button(action: {
                    modal = false
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack{
                        Image(systemName: "chevron.left")
                        Text("Atrás")
                    }
                }
            }
        }
    }
    
    private func saveDirection() {
        let query = FetchDescriptor<UserSD>()
        let token = try? context.fetch(query).first?.token
        
        switch options {
            case .addDirection(_):
                let data: [String : Any] = [
                    "full_address": direction!.full_address,
                    "name" : name_direction,
                    "latitude": direction!.latitude,
                    "longitude": direction!.longitude,
                    "reference" : references
                ]
                
                api.fetch(
                    url: "address/add", method: "POST", body: data, token: token! ,
                    ofType: SaveDirectionsResponse.self
                ) { response, status in
                    if status {
                        if response!.status == "success" {
                            reload = direction!.full_address
                            modal = false
                            presentationMode.wrappedValue.dismiss()
                        } else {
                            alert = true
                        }
                    }
                }
                
            case .editDirection(let address):
                let data: [String : Any] = [
                    "full_address": direction!.full_address,
                    "name" : name_direction,
                    "latitude": direction!.latitude,
                    "longitude": direction!.longitude,
                    "reference" : references,
                    "id_address": address.id
                ]
                
                if address.id == 0 {
                    api.fetch(
                        url: "address/add", method: "POST", body: data, token: token! ,
                        ofType: SaveDirectionsResponse.self
                    ) { response, status in
                        if status {
                            if response!.status == "success" {
                                reload = direction!.full_address
                                modal = false
                            
                                context.delete(address)
                                try! context.save()
                                    
                                presentationMode.wrappedValue.dismiss()
                            } else {
                                alert = true
                            }
                        }
                    }
                } else {
                    api.fetch(url: "address/update", method: "POST", body: data, token: token!, ofType: SaveDirectionsResponse.self){ res, status in
                        if status{
                            if res!.status == "success" {
                                address.name = name_direction
                                address.reference = references
                                address.latitude = String(direction!.latitude)
                                modal = false
                                address.longitude = String(direction!.longitude)
                                presentationMode.wrappedValue.dismiss()
                            } else {
                                alert = true
                            }
                        }
                    }
                }
        }
    }
    
    private func cameraPosition(){
        switch options {
        case .addDirection(let address):
            geocodeDirection(address: address) { res in
                title = "Agregar dirección"
                span = .init(latitudeDelta: 0.006, longitudeDelta: 0.006)
                direction = TemporalDirection(full_address: "\(address.title) \(address.subtitle)", latitude: res.latitude, longitude: res.longitude)
                position = CLLocationCoordinate2D(latitude: res.latitude, longitude: res.longitude)
                coords = .region(MKCoordinateRegion(center: position!, span: span))
            }
                                              
        case .editDirection(let address):
            title = "Editar dirección"
            name_direction = address.name
            references = address.reference
            span = MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
            position = CLLocationCoordinate2D(latitude: Double(address.latitude)!, longitude: Double(address.longitude)!)
            direction = TemporalDirection(full_address: address.full_address, latitude: position!.latitude, longitude: position!.longitude)
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
