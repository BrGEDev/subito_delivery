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
    //SwiftData
    
    @Environment(\.modelContext) var context
    @Query(sort: \DirectionSD.id, order: .forward) var directions: [DirectionSD]
        //
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    @StateObject var locationManager: LocationManager = .init()
    @State var location: CLLocation = .init()
    @StateObject var DeliveryAddress: DeliveryAddress = .init()
    
    @State var address: String = ""
    
    @StateObject var api: ApiCaller = ApiCaller()
    @State var path = NavigationPath()
    
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
                
                Section(header:Text(DeliveryAddress.searchText != "" ? "Direcciones encontradas" : "Mis direcciones")){
                    if DeliveryAddress.searchText != "" {
                        ForEach(DeliveryAddress.results) { address in
                            AddressRow(address: address)
                                .onTapGesture {
                                    createDirection(address: address)
                                }
                                .listRowBackground(Color.white.opacity(0))
                                .listRowInsets(EdgeInsets())
                                .listRowSeparator(.hidden)
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
            .toolbar{
                ToolbarItem(placement: .topBarTrailing){
                    EditButton()
                }
            }
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
            .navigationTitle("Seleccionar dirección")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: DirectionSD.self){ view in
                EditDirection(address: view)
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
    
    var body: some View {
        ZStack{
            ZStack(alignment: .top){
                Map(position: $coords){
                    if position != nil {
                        Annotation("", coordinate: position!) {
                            Image(.home)
                                .resizable()
                                .frame(width: 60, height: 60)
                        }
                    }
                }
                .ignoresSafeArea()
                .mapControlVisibility(.hidden)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            
        }
        .navigationTitle("Editar dirección")
        .onAppear {
            cameraPosition()
        }
        .sheet(isPresented: $modalInfo){
            ScrollView {
                
            }
            .presentationDetents([.fraction(0.30), .fraction(0.85)])
            .presentationBackgroundInteraction(.enabled)
            .presentationDragIndicator(.visible)
            .interactiveDismissDisabled(true)
            .presentationCornerRadius(35)
            .presentationBackground(Material.bar)
        }
    }
    
    private func cameraPosition(){
        position = CLLocationCoordinate2D(latitude: Double(address.latitude)!, longitude: Double(address.longitude)!)
        coords = .region(MKCoordinateRegion(center: position!, span:  MKCoordinateSpan(latitudeDelta: 0.006, longitudeDelta: 0.003)))
    }
}
