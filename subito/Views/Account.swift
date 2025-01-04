//
//  Account.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 09/09/24.
//

import SwiftData
import SwiftUI

struct Account: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var vm: UserStateModel
    
    @State private var search = ""
    @State private var closeSesion: Bool = false
    
    @StateObject var api: ApiCaller = ApiCaller()
    @Query var userData: [UserSD]
    var user: UserSD? { userData.first }
    
    var body: some View{
        NavigationView{
            List {
                VStack{
                    Image(.burger)
                        .resizable()
                        .frame(width: 90, height: 90)
                        .clipShape(Circle())
                        .clipped()
                    
                    Text("\(user?.name  ?? "") \(user?.lastName  ?? "")")
                        .font(.title)
                        .lineLimit(1)
                        .bold()
                    
                    Text(verbatim: user?.email ?? "")
                        .foregroundStyle(.secondary)
                        .font(.headline)
                        .fontWeight(.regular)
                }
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .listSectionSeparator(.hidden)
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.white.opacity(0))
                
                Section(header: Text("Cuenta")){
                    
                    NavigationLink(destination: EmptyView()){
                        Label("Mi perfil", systemImage: "person.crop.circle.fill")
                    }
                
                }
                
                Section(header: Text("Pagos")){
                    NavigationLink(destination: Wallet()){
                        Label("Mis métodos de pago", systemImage: "creditcard.fill")
                    }
                }
                
                Section(header: Text("Configuración")){
                    
                    NavigationLink(destination: EmptyView()){
                        Label("Apariencia", systemImage: "circle.lefthalf.striped.horizontal.inverse")
                    }
                    
                    NavigationLink(destination: EmptyView()){
                        Label("Notificaciones", systemImage: "bell.badge.fill")
                    }
        
                }
                .listRowSeparator(.hidden)
                
                Section(header: Text("Ayuda")){
                    NavigationLink(destination: Support()){
                        Label("Soporte técnico", systemImage: "phone.bubble.fill")
                    }
                
                }
                
                Button("Cerrar sesión"){
                    closeSesion = true
                }
                .alert(isPresented: $closeSesion){
                    Alert(title: Text("Cerrar sesión"), message: Text("¿Estás seguro de cerrar sesión?"), primaryButton: .default(Text("Aceptar")){
                        Task {
                            await vm.signOut()
                        }
                    }, secondaryButton: .cancel(Text("Cancelar")))
                }
                .foregroundColor(.red)
                .frame(maxWidth: .infinity, alignment: .center)
                
            }
            .navigationTitle("Configuración")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
