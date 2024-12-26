//
//  CartModal.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 01/10/24.
//


import SwiftUI
import SwiftData

struct productoView: View {
    @StateObject var api: ApiCaller = ApiCaller()
    
    @Environment(\.modelContext) var context
    @State var product: ProductsSD
    var establishment: Int
    @Binding var onDelete: Bool

    var body: some View {
        VStack{
            HStack{
                VStack{
                    AsyncImage(url: URL(string: product.image)){ image in
                        image
                            .resizable()
                    } placeholder: {
                        ProgressView()
                    }
                }
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .clipped()
                
                VStack{
                    Text(product.product)
                        .bold()
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                    
                    Text("x\(product.amount)")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                }
                .padding(.trailing, 10)
                
                Spacer()
                
                Text(product.unit_price * Float(product.amount), format: .currency(code: "MXN"))
                    .bold()
                
                Button(action: {
                    delete(product: product)
                }){
                   Image(systemName: "minus.circle.fill")
                }
                .tint(Color.red)
            }
            .padding()
        }
    }
}

struct CartModal: View {
    @Environment(\.modelContext) var context
    @Binding var isPresented: Bool
    
    @StateObject var api: ApiCaller = ApiCaller()
    var socket: SocketService
  
    @Query var establishments: [CartSD]
    @State var payment: Float = 0
    @State var onDelete: Bool = false
    
    var body: some View {
        NavigationView{
            VStack{
                if establishments.count != 0{
                    ScrollView{
                        ForEach(establishments){ est in
                            VStack{
                                HStack{
                                    Text(est.establishment)
                                        .font(.title3)
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        deleteAll()
                                    }){
                                        Image(systemName: "trash")
                                            .font(.system(size: 15))
                                    }
                                    .foregroundStyle(Color.red)
                                }
                                .padding()
                                
                                ForEach(est.products){ prod in
                                    productoView(product: prod, establishment: est.id, onDelete: $onDelete)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Material.ultraThin)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(color: Color.black.opacity(0.15), radius: 10)
                            .padding()
                        }
                    }
                    
                    HStack(spacing: 15){
                        NavigationLink(destination: PaymentModal(socket: socket, isPresented: $isPresented)){
                            Text("Pagar \(Text(payment, format: .currency(code: "MXN")))")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .font(.system(size: 18))
                                .bold()
                        }
                        .foregroundColor(.black)
                        .frame(height: 50)
                        .background(.accent)
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.2), radius: 10)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                } else {
                    VStack{
                        Image(.logo)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                        
                        Text("Aún no hay productos en tu carrito")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: 300, maxHeight:300)
                }
            }
            .navigationTitle("Mi carrito")
            .toolbar {
                Button(action: {
                    isPresented = false
                }){
                    Image(systemName: "xmark").padding(.trailing, 8)
                }
                .foregroundColor(.white)
                .frame(width: 30, height: 30)
                .background(Color.black)
                .cornerRadius(1000)
                .shadow(color: Color.black.opacity(0.4) ,radius: 5)
            }
            .onAppear{
                loadPayment()
            }
            .onChange(of: onDelete) { oldValue, newValue in
                loadPayment()
            }
        }
    }
}
