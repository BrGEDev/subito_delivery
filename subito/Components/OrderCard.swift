//
//  OrderCard.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 19/12/24.
//

import SwiftUI

struct OrderCard: View {
    @Environment(\.colorScheme) var colorScheme
    var order: Orders
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack{
                VStack {
                    AsyncImage(url: URL(string: "https://dev-da-pw.mx/APPRISA/\(order.picture_logo)")) { image in
                        image
                            .resizable()
                    } placeholder: {
                        ProgressView()
                    }
                }
                .frame(width: 40, height: 40)
                .scaledToFill()
                .clipShape(Circle())
                .clipped()
                
                Text(order.name_restaurant)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .bold()
            }
            
            HStack{
                VStack(alignment: .leading){
                    Text(order.status == "Pendiente" ? "Tu pedido está en espera" : (order.status == "Recolectando" || order.status == "Buscar repartidor" ? "Tu pedido se encuentra en preparación" : "Tu pedido se encuentra en camino"))
                        .font(.system(size: 25))
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                Image(order.status == "Recolectando" || order.status == "Buscar repartidor" ||  order.status == "Pendiente" ? .tienda : .repartidor)
                    .resizable()
                    .frame(width: 75, height: 75)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("Tiempo estimado de entrega: \(formatDate(date: order.time_order, created_at: order.created_at))")
                .font(.system(size: 14))
        }
        .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Material.bar)
        .clipShape(RoundedRectangle(cornerRadius: 25))
        .clipped()
        .shadow(color: Color.black.opacity(0.1), radius: 10)
        .padding()
    }
    
    private func formatDate(date: String, created_at: String) -> String {
        let create = try! dateFromString(string: created_at)
        let time = date.split(separator: ":")
        
        let calendar = Calendar.current
        var newDate = calendar.date(byAdding: .minute, value: Int(time[1])!, to: create!)
        newDate = calendar.date(byAdding: .hour, value: Int(time[0])!, to: newDate!)
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: newDate!)
    }
    
    private func dateFromString(string: String) throws -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_MX")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS"
        return formatter.date(from: string)
    }
}

struct ListOrderCard: View {
    @Environment(\.colorScheme) var colorScheme
    
    var orders: [Orders] = []
    var body: some View {
        VStack(alignment:.leading){
            Text("Tienes órdenes en curso...")
                .font(.title2)
                .bold()
            
            HStack{
                ForEach(orders.prefix(upTo: orders.count >= 4 ? 4 : orders.count), id: \.id_order) { order in
                    if order.status != "Cancelado" {
                        AsyncImage(url: URL(string: "https://dev-da-pw.mx/APPRISA/\(order.picture_logo)")) { image in
                            
                            image
                                .resizable()
                                .frame(width: 70, height: 70)
                                .scaledToFill()
                                .clipShape(Circle())
                                .clipped()
                        } placeholder: {
                            ProgressView()
                                .frame(width: 60, height: 60)
                                .scaledToFill()
                                .clipShape(Circle())
                                .clipped()
                        }
                    }
                }
            }
        }
        .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Material.bar)
        .clipShape(RoundedRectangle(cornerRadius: 25))
        .clipped()
        .shadow(color: Color.black.opacity(0.1), radius: 10)
        .padding()
    }
}

struct ListOrders: View{
    var orders: [Orders]
    var body: some View {
        VStack{
            ScrollView {
                ForEach(orders, id: \.id_order) { item in
                    if item.status != "Cancelado" {
                        NavigationLink(destination: OrderDetail(order: item.id_order)) {
                            OrderCard(order: item)
                        }
                    }
                }
            }
        }
        .navigationTitle("Mis órdenes")
        .navigationBarTitleDisplayMode(.large)
    }
}

