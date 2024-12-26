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
                    VStack{
                        NavigationLink(destination: EmptyView()){
                            Label("Editar perfil", systemImage: "person.crop.circle.fill")
                        }
                        
                        NavigationLink(destination: EmptyView()){
                            Label("Contraseña", systemImage: "key.fill")
                        }
                    }
                }
                .listRowBackground(Color(colorScheme == .dark ? .white.opacity(0.1) : .white).clipped().cornerRadius(20))
                
                Section(header: Text("Pagos")){
                    VStack{
                        NavigationLink(destination: Wallet()){
                            Label("Mis métodos de pago", systemImage: "creditcard.fill")
                        }
                    }
                }
                .listRowBackground(Color(colorScheme == .dark ? .white.opacity(0.1) : .white).clipped().cornerRadius(20))
                
                Section(header: Text("Configuración")){
                    VStack{
                        NavigationLink(destination: EmptyView()){
                            Label("Apariencia", systemImage: "circle.lefthalf.striped.horizontal.inverse")
                        }
                        
                        NavigationLink(destination: EmptyView()){
                            Label("Notificaciones", systemImage: "bell.badge.fill")
                        }
                    }
                }
                .listRowBackground(Color(colorScheme == .dark ? .white.opacity(0.1) : .white).clipped().cornerRadius(20))
                
                Section(header: Text("Ayuda")){
                    VStack{
                        NavigationLink(destination: EmptyView()){
                            Label("Soporte técnico", systemImage: "phone.bubble.fill")
                        }
                    }
                }
                .listRowBackground(Color(colorScheme == .dark ? .white.opacity(0.1) : .white).clipped().cornerRadius(20))
                
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
                .listRowBackground(Color(colorScheme == .dark ? .white.opacity(0.1) : .white).clipped().cornerRadius(20))
                
            }
            .navigationTitle("Configuración")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
