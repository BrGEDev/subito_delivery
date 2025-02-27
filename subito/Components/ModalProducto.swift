//
//  ModalProducto.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 19/11/24.
//

import SwiftUI
import SwiftData

struct ModalProducto: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var context
    @StateObject var api: ApiCaller = ApiCaller()
    
    var location: [String:Any]
    var data: Product
    @State var count: Int = 1
    @State var advertencia: Bool = false
    @State var token : String = ""
    
    var body: some View {
        VStack{
            ScrollView{
                ZStack{
                    GeometryReader { imageGeo in
                        let image = URL(string: data.pd_image ?? "")
                        
                        AsyncImageCache(url: image) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: Screen.width, height: 420, alignment: .center)
                                .clipped()
                                .offset(x: 0, y: self.getOffsetY(basedOn: imageGeo))
                        } placeholder: {
                            ProgressView()
                                .frame(width: Screen.width, height: 420, alignment: .center)
                                .frame(maxWidth: .infinity)
                                .offset(x: 0, y: self.getOffsetY(basedOn: imageGeo))
                        }
                        .scaledToFill()
                        .frame(width: Screen.width, height: 340, alignment: .top)
                        .clipped()
                    }
                    .scaledToFill()
                    
                    VStack{
                        HStack{
                            Spacer()
                            
                            Button(action: {
                                dismiss()
                            }){
                                Image(systemName: "xmark")
                                    .foregroundStyle(Color.black)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.white)
                            .buttonBorderShape(.circle)
                            .shadow(radius: 17)
                        }
                        .padding(.top, 90)
                        
                        Spacer()
                    }
                    .padding()
                }
                .frame(minHeight: 250, maxHeight: 250)
                
                Spacer(minLength: 15)
                
                VStack(spacing: 25){
                    Text(data.pd_name)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .bold()
                        .font(.largeTitle)
                        .multilineTextAlignment(.leading)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text(data.pd_description ?? data.pd_name)
                        Text("\(Image(systemName: "shippingbox")) Stock disponible: \(data.pd_quantity ?? "0")")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Precio unitario")
                        Text(Float(data.pd_unit_price)!, format: .currency(code: "MXN"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .bold()
                            .font(.title2)
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(Color.accentColor)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            HStack(spacing: 15){
                Stepper(value: $count, in: 1...10, max: data.pd_quantity ?? "0")
                    .controlSize(.regular)
                    .frame(width: 120)
                
                Button(action: {
                   addToCart()
                }){
                    let price = Float(data.pd_unit_price)! * Float(count)
                    
                    Text("Agregar \(Text(price, format: .currency(code: "MXN")))")
                        .padding()
                        .font(.system(size: 18))
                        .bold()
                }
                .disabled(data.pd_quantity ?? "0" == "0" ? true : false)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(data.pd_quantity ?? "0" == "0" ? .accent.opacity(0.5) : .accent)
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.2), radius: 10)
                .alert(isPresented: $advertencia){
                    Alert(title: Text("Advertencia"), message: Text("Tienes productos de otro establecimiento, ¿deseas eliminar los productos anteriores y agregar los nuevos?"), primaryButton: .default(Text("Agregar nuevos")){saveNew()}, secondaryButton: .destructive(Text("Cancelar")))
                }
                
            }
            .frame(maxWidth: .infinity)
            .padding()
            .onAppear{
                let query = FetchDescriptor<UserSD>()
                token = try! context.fetch(query).first!.token
            }
        }
    }
}
