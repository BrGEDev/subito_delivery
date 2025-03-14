//
//  HistoryOrderDetail.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 14/03/25.
//

import SwiftData
import SwiftUI

struct HistoryOrderDetail: View {

    var order: HistoryData
    @StateObject var api = ApiCaller()
    @State var detail: OrderDetails?

    @Query var userData: [UserSD]
    var user: UserSD? { userData.first }

    @State var loading: Bool = true
    
    var body: some View {
        ScrollView {
            if loading {
                ZStack {
                    Spacer().containerRelativeFrame([.horizontal, .vertical])
                    VStack {
                        ProgressView(){
                            Text("Cargando pedido...")
                        }
                    }
                }
            } else {
                if detail != nil {
                    
                    let color = switch (detail!.order!.id_status) {
                        case "24":
                            Color.green
                        case "39", "41", "40":
                            Color.red
                        default:
                            Color.yellow
                    }
                    
                    LazyVStack(alignment: .leading, spacing: 35) {
                        HStack {
                            Text("Orden #\(order.no_order)")
                            
                            Spacer()
                            
                            Text(order.status)
                                .bold()
                                .foregroundStyle(color)
                                .padding()
                                .background(Capsule().fill(color.opacity(0.1)))
                        }
                        
                        Label("Tiempo de preparación: \(order.time_order)", systemImage: "clock.fill")
                        
                        Label(detail!.order!.ad_full_address, systemImage: "mappin.circle.fill")
                        
                        if detail!.order!.id_delivery != nil {
                            VStack(alignment: .leading, spacing: 10){
                                Text("Repartidor")
                                    .font(.title3.bold())
                                
                                Text("\(detail!.order!.name!) \(detail!.order!.last_name!)")
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 15){
                            
                            Text("Productos")
                                .font(.title3.bold())
                            
                            ForEach(detail!.products!, id:\.pd_name) { product in
                                HStack {
                                    AsyncImageCache(url: URL(string: product.pd_image)) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(width: 60, height: 60)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .clipped()
                                    
                                    VStack(alignment: .leading) {
                                        Text(product.pd_name)
                                            .bold()
                                        
                                        Text("Cantidad: \(product.sp_quantity)")
                                        
                                        HStack{
                                            Text("Precio unitario: ")
                                            Text(Double(product.pd_unit_price)!, format: .currency(code: "MXN"))
                                        }
                                        .foregroundStyle(Color.green)
                                    }
                                }
                                .padding(8)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                .background(Material.bar)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .clipped()
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Text("Costo de envío:")
                                
                                Spacer()
                                
                                Text(Double(detail!.order!.costo_envio)!, format: .currency(code: "MXN"))
                            }
                            
                            HStack{
                                Text("Subtotal:")
                                
                                Spacer()
                                
                                Text(Double(detail!.order!.total)!, format: .currency(code: "MXN"))
                            }
                            
                            Divider()
                            
                            HStack{
                                Text("Total:")
                                
                                Spacer()
                                
                                Text(Double(detail!.order!.total)! + Double(detail!.order!.costo_envio)!, format: .currency(code: "MXN"))
                            }
                            .font(.title3.bold())
                        }
                        .padding()
                        .background(Color.green.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .clipped()
                        
                        VStack(spacing: 15) {
                            Text("Orden entregada")
                                .font(.title3.bold())
                            
                            AsyncImageCache(url: URL(string: "https://da-pw.mx/APPRISA/\(detail!.order!.picture_order ?? "")")) { image in
                                image.resizable()
                            } placeholder: {
                                ProgressView()
                            }
                            .scaledToFill()
                            .frame(width: 300, height: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                            .clipped()
                            .shadow(radius: 5)
                        }
                        .padding(.bottom)
                        .frame(maxWidth:.infinity, alignment: .center)
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                        .clipped()
                    }
                    .padding()
                }
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .navigationTitle(order.name_restaurant)
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            loadOrder()
        }
    }
}

extension HistoryOrderDetail {

    func loadOrder() {
        loading = true
        api.fetch(
            url: "orders/details/\(order.id_order)", method: "GET", token: user!.token, ofType: DetailOrderResponse.self
        ) { res, status in
            loading = false
            
            if status {
                if res!.status == "success" {
                    detail = res!.data
                }
            }
        }
    }

}
