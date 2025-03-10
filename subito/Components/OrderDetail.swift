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
    @ObservedObject var router = NavigationManager.shared
    
    var order: String
    var socket = SocketService.socketClient
    @State var orderDetails: OrderDetails?
    @StateObject var api: ApiCaller = ApiCaller()
    @Query var userData: [UserSD]
    var user: UserSD? { userData.first }
    
    @StateObject var locationManager: LocationManager = .init()
    @State var coords: MapCameraPosition = .region(MKCoordinateRegion(center: .Puebla, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)))
    @State var clientCoords: CLLocationCoordinate2D?
    @State var establishmentCoords: CLLocationCoordinate2D?
    @State var repartidorCoords: CLLocationCoordinate2D?
    @State var modalInfo: Bool = true
    
    @State var estimatedTime: String = ""
    @State var fraction: PresentationDetent = .fraction(0.18)
    
    @State var status: Int = 0
    @State var statusString: String = "Cargando..."
    @State var reasonCancel: String = "Cancelado por swd    qswd qsad ade  sqwda"
    
    var body: some View {
        ZStack{
                VStack(alignment:.leading){
                    ZStack{
                        VStack{
                            HStack{
                                Button(action: {
                                    modalInfo = false
                                    router.navigationPath.removeLast()
                                }){
                                    Image(systemName: "arrow.backward")
                                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                                }
                                
                                Spacer()
                            }
                            .padding(.bottom, 10)
                            
                            VStack(alignment:.leading, spacing: 10){
                                HStack{
                                    Text(statusString)
                                        .font(.title)
                                        .bold()
                                    
                                    Spacer()
                                    
                                    Image(.pendiente)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 30, height: 30)
                                }
                                
                                if status != 39 {
                                    Text("Llegada estimada: \(estimatedTime)")
                                        .font(.subheadline)
                                }
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
                            bottomLeadingRadius: fraction == .fraction(0.18) ? 35 : 0,
                            bottomTrailingRadius: fraction == .fraction(0.18) ? 35 : 0,
                            topTrailingRadius: 0
                        )
                    )
                    .shadow(color: Color.black.opacity(0.15), radius: 15)
                    .animation(Animation.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.6), value: modalInfo)
                    
                    Spacer()
                }
                .zIndex(20)
                
            
            if status != 39 {
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
                        
                        if repartidorCoords != nil {
                            Annotation("", coordinate: repartidorCoords!) {
                                Image(.repartidor)
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
                                if orderDetails != nil {
                                    AsyncImageCache(url: URL(string: "https://da-pw.mx/APPRISA/\(orderDetails?.order?.picture_logo ?? "")")) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    } placeholder : {
                                        ProgressView()
                                    }
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
                                        
//                                        Button(action: {
//                                            // Iniciar chat con repartidor
//                                        }){
//                                            Label("Mensaje", systemImage: "ellipsis.message")
//                                                .frame(maxWidth: .infinity)
//                                        }
//                                        .foregroundStyle(colorScheme == .dark ? .white : .black)
//                                        .padding()
//                                        .background(Material.bar)
//                                        .clipShape(RoundedRectangle(cornerRadius: 20))
//                                        .clipped()
//                                        .frame(maxWidth: .infinity)
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
                    .presentationDetents([.fraction(0.18), .fraction(0.85)], selection: $fraction)
                    .presentationBackgroundInteraction(.enabled)
                    .presentationDragIndicator(.visible)
                    .interactiveDismissDisabled(true)
                    .presentationCornerRadius(fraction == .fraction(0.18) ? 35 : 0)
                    .presentationBackground(Material.bar)
                }
            }
            else {
                VStack{
                    Image(systemName: "x.circle")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundStyle(Color.red)
                        .padding(.bottom, 30)
                    
                    VStack(alignment: .leading, spacing: 20){
                        Text("El establecimiento rechazó tu pedido por el siguiente motivo: ")
                        Text(reasonCancel)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 30)
                    
                    Button(action: {
                        router.navigationPath.removeLast()
                    }) {
                        Text("Volver al inicio")
                    }
                    .padding()
                    .foregroundColor(.black)
                    .background(Color.accentColor)
                    .cornerRadius(20)
                    .frame(width: 200, height: 50)
                }
                .padding()
            }
        }
        .ignoresSafeArea()
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .onAppear{
            detailOrder()
        }
        .onChange(of: statusString) { oldValue, newValue in
            
            print("El valor anterior es \(oldValue)")
            print("El nuevo valor es \(newValue)")
            
            if oldValue != newValue {
                let title: String = switch statusString {
                    case "Recolectando", "En espera":
                        "Tu pedido está en preparación"
                    case "Esperando producto":
                        "El repartidor ha llegado a \(orderDetails?.order?.name_restaurant ?? "")"
                    case "Delivery":
                        "El repartidor va camino a tu domicilio"
                    case "En pago":
                        "El repartidor ha llegado, ¡recolecta tu pedido!"
                    default:
                        "Pedido terminado"
                }
                
                UIApplication.shared.inAppNotification {
                    let activeWindow =
                    (UIApplication.shared.connectedScenes.first
                     as? UIWindowScene)?
                        .windows.first(where: { $0.tag == 0320 })
                    
                    HStack {
                        Image(statusString == "Recolectando" || statusString == "En espera" ? .tienda : .repartidor)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .padding(2)
                        .background(
                            Circle().fill(.gray.opacity(0.5))
                        )
                        .clipped()
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text(title)
                                .font(.callout.bold())
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Text("Su número de pedido es \(orderDetails?.order?.no_order ?? "")")
                                .font(.caption)
                                .foregroundStyle(.secondary)                        }
                        .padding(
                            .top, activeWindow != nil &&
                            activeWindow!.safeAreaInsets.top >= 51 ? 20 : 0)
                        
                        Spacer(minLength: 0)
                    }
                    .foregroundStyle(.white)
                    .padding(15)
                    .background(
                        RoundedRectangle(cornerRadius: 15).fill(.black)
                    )
                }
            }
        }
        .onDisappear {
            socket.clearListener(listener: "sendLocation")
            socket.clearListener(listener: "orderCanceled")
            socket.clearListener(listener: "responseAutoAsign")
        }
    }
}
