//
//  Wallet.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 09/09/24.
//

import SwiftUI

struct Wallet: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var applepay: Bool = true
    @State private var efectivo: Bool = false
    
    
    var body: some View {
        
        List{
            VStack{
                ZStack{
                    RoundedRectangle(cornerRadius: 30)
                        .foregroundColor(Color.white.opacity(0))
                        .frame(minWidth: 0,maxWidth: .infinity,minHeight: 0,maxHeight: .infinity)
                        .background(Material.thin)
                        .cornerRadius(30)
                        .shadow(color: Color.black.opacity(0.15),radius: 10)
                    
                    VStack{
                        HStack{
                            Text("Saldo Súbito").frame(maxWidth: .infinity, alignment: .leading)
                            
                            Spacer()
                            
                            Image(.logo)
                                .resizable()
                                .frame(width: 30, height: 30)
                        }
                        
                        Spacer(minLength: 15)
                        
                        HStack{
                            Text(0, format: .currency(code: "MXN"))
                                .font(.largeTitle).bold().frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(20)
                }
            }
            .listSectionSeparatorTint(Color.white.opacity(0))
            .padding(15)
            .listRowBackground(Color.white.opacity(0))
            .listRowInsets(EdgeInsets())
            
            
            Section("Métodos de pago"){
//                Toggle(isOn: $applepay){
//                    Label("Apple Pay", systemImage: "apple.logo")
//                }
//                .toggleStyle(SwitchToggleStyle(tint: .accentColor))
//                
//                Toggle( isOn: $efectivo){
//                    Label("Efectivo", systemImage: "banknote.fill")
//                }
//                .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                
                NavigationLink(destination: PaymentMethod()){
                    Label("Tarjetas de débito / crédito", systemImage: "creditcard.fill")
                }
            }
            .listSectionSeparatorTint(Color.white.opacity(0))
            .padding(20)
            .listRowInsets(EdgeInsets())
            
            Section("Promociones"){
                NavigationLink(destination: EmptyView()){
                    Label("Mis cupones", systemImage: "ticket.fill")
                }
            }
            .listSectionSeparatorTint(Color.white.opacity(0))
            .padding(20)
            .listRowInsets(EdgeInsets())
        }
        .listStyle(.grouped)
        .scrollContentBackground(.hidden)
        .navigationTitle("Billetera")
        
    }
}
