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
    
    var body: some View {
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
                                .listRowBackground(Color.white.opacity(0))
                                .listRowInsets(EdgeInsets())
                                .listRowSeparator(.hidden)
                                .listSectionSeparator(.hidden)
                        }
                        .onDelete(perform: deleteDirection)
                    }
                }
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
    }
}



#Preview {
    DirectionsModal()
        .modelContainer(for: [DirectionSD.self, UserSD.self])
}
