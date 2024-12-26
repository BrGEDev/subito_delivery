//
//  OrderDetail.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 19/12/24.
//

import SwiftUI
import MapKit
import SwiftData

struct OrderDetail: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    var order: Orders
    @State var orderDetails: OrderDetails?
    @StateObject var api: ApiCaller = ApiCaller()
    @Query var userData: [UserSD]
    var user: UserSD? { userData.first }
    
    @StateObject var locationManager: LocationManager = .init()
    @State var coords: MapCameraPosition = .region(MKCoordinateRegion(center: .Puebla, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)))
    @State var clientCoords: CLLocationCoordinate2D?
    @State var establishmentCoords: CLLocationCoordinate2D?
    @State var showMap: Bool = false
    @State var modalInfo: Bool = true
    
    @State var estimatedTime: String = ""
    
    var body: some View {
        ZStack{
            VStack(alignment:.leading){
                ZStack{
                    VStack{
                        HStack{
                            Button(action: {
                                modalInfo = false
                                dismiss()
                            }){
                                Image(systemName: "arrow.backward")
                                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                            }
                            
                            Spacer()
                        }
                        .padding(.bottom, 10)
                        
                        VStack(alignment:.leading, spacing: 10){
                            HStack{
                                Text(orderDetails?.order?.status ?? "Cargando...")
                                    .font(.title)
                                    .bold()
                                
                                Spacer()
                                
                                Image(.pendiente)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 30, height: 30)
                            }
                            
                            Text("Llegada estimada: \(estimatedTime)")
                                .font(.subheadline)
                        }
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 20)
                    }
                }
                .padding(.top,60)
                .padding([.leading, .trailing])
                .frame(maxWidth: .infinity)
                .background(Material.bar)
                .clipShape(
                    .rect(
                        topLeadingRadius: 0,
                        bottomLeadingRadius: 35,
                        bottomTrailingRadius: 35,
                        topTrailingRadius: 0
                    )
                )
                .shadow(color: Color.black.opacity(0.15), radius: 15)
                
                Spacer()
            }
            .zIndex(20)
            
            ZStack(alignment: .top){
                Map(position: $coords){
                    UserAnnotation()
                    
                    if establishmentCoords != nil {
                        Annotation("", coordinate: establishmentCoords!) {
                            Image(.tienda)
                                .resizable()
                                .frame(width: 60, height: 60)
                        }
                    }
                    
                    if clientCoords != nil {
                        Annotation("", coordinate: clientCoords!) {
                            Image(.home)
                                .resizable()
                                .frame(width: 50, height: 50)
                        }
                    }
                }
                .ignoresSafeArea()
                .mapControlVisibility(.hidden)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            .sheet(isPresented: $modalInfo){
                ScrollView {
                    Spacer(minLength: 20)
                    HStack{
                        VStack{
                            AsyncImage(url: URL(string: "https://dev-da-pw.mx/APPRISA/\(orderDetails?.order?.picture_logo ?? "")")) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder : {
                                ProgressView()
                            }
                        }
                        .frame(width: 80, height: 80)
                        .background(Material.bar)
                        .clipShape(Circle())
                        .clipped()
                        
                        VStack(alignment: .leading){
                            Text(orderDetails?.order?.name_restaurant ?? "Cargando...")
                                .font(.title2)
                                .multilineTextAlignment(.leading)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .bold()
                            
                            Button(action: {
                                callto(phone: orderDetails?.order?.establishment_phone ?? "")
                            }){
                                Label("Llamar", systemImage: "phone")
                                    .frame(maxWidth: .infinity)
                            }
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                            .padding()
                            .background(Material.bar)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .clipped()
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    
                    if orderDetails?.order?.id_delivery != nil{
                        
                        HStack{
                            VStack(alignment: .leading){
                                Text("\(orderDetails?.order?.name ?? "") \(orderDetails?.order?.last_name ?? "")")
                                    .font(.title2)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .bold()
                                
                                HStack{
                                    Button(action: {
                                        callto(phone: orderDetails?.order?.delivery_phone ?? "")
                                    }){
                                        Label("Llamar", systemImage: "phone")
                                            .frame(maxWidth: .infinity)
                                    }
                                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                                    .padding()
                                    .background(Material.bar)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .clipped()
                                    .frame(maxWidth: .infinity)
                                    
                                    Button(action: {
                                        // Iniciar chat con repartidor
                                    }){
                                        Label("Mensaje", systemImage: "ellipsis.message")
                                            .frame(maxWidth: .infinity)
                                    }
                                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                                    .padding()
                                    .background(Material.bar)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .clipped()
                                    .frame(maxWidth: .infinity)
                                }
                            }
                            
                            VStack{
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                            }
                            .frame(width: 70, height: 70)
                            .background(Material.bar)
                            .clipShape(Circle())
                            .clipped()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        
                    }
                    
                    VStack(alignment: .leading, spacing: 20){
                        Text("Detalles de la entrega")
                            .font(.title)
                            .bold()
                        
                        Spacer(minLength: 10)
                        
                        HStack(spacing: 10){
                            Text("Dirección")
                                .bold()
                            
                            Spacer()
                            
                            Text(orderDetails?.order?.ad_full_address ?? "")
                                .multilineTextAlignment(.trailing)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        
                        if orderDetails != nil {
                            HStack(spacing: 10){
                                Text("Tu pedido")
                                    .bold()
                                
                                Spacer()
                                
                                VStack(spacing: 5){
                                    ForEach(orderDetails!.products!, id: \.pd_name){ product in
                                        VStack(alignment: .trailing){
                                            Text(product.pd_name)
                                            Text("x \(product.sp_quantity)")
                                        }
                                        .multilineTextAlignment(.trailing)
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                    }
                                }
                            }
                        }
                        
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
                .presentationDetents([.fraction(0.18), .fraction(0.85)])
                .presentationBackgroundInteraction(.enabled)
                .presentationDragIndicator(.visible)
                .interactiveDismissDisabled(true)
                .presentationCornerRadius(35)
                .presentationBackground(Material.bar)
            }
        }
        .ignoresSafeArea()
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .onChange(of: locationManager.isLocationAuthorized) { oldVal, newVal in
            if newVal {
                showMap = true
            }
        }
        .onAppear{
            detailOrder()
        }
    }
}
