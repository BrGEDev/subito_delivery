//
//  Support.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 03/01/25.
//

import SwiftUI

struct TypeSupport: Hashable, Identifiable {
    var id: Int
    var icon: String
    var title: String
    var description: String
}

struct Support: View {
    @Environment(\.modelContext) var context
    
    @StateObject var api: ApiCaller = ApiCaller()
    
    var types: [TypeSupport] = [
        .init(id: 2, icon: "phone.arrow.up.right.fill", title: "Call center", description: "Problemas con un pedido, producto incompleto, etc."),
        .init(id: 3, icon: "banknote.fill", title: "Tesorería", description: "Problemas con los pagos, aclaración del cobro de servicio, etc."),
        .init(id: 1, icon: "iphone.gen3",title: "Soporte técnico", description: "Problemas con la aplicación, problemas con mi cuenta, etc."),
    ]
    
    var body: some View {
        VStack{
            
            Text("Elige el tipo de soporte que necesitas. Si no sabes que tipo de problema tienes, puedes comunicarte con call center de Súbito.")
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            
            List(types, id:\.self){ type in
                NavigationLink(destination: Chat(title: type.title, options: .create(support: type.id))){
                    Label(title: {
                        VStack(alignment: .leading){
                            Text(type.title)
                                .font(.title3.bold())
                            
                            Text(type.description)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }, icon: {
                        Image(systemName: type.icon)
                    })
                }
                .padding([.top, .bottom])
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Centro de soporte")
        .scrollContentBackground(.hidden)
        .onAppear {
            loadChats()
        }
    }
}

#Preview {
    NavigationView {
        Support()
    }
    .modelContainer(for: [
        UserSD.self, DirectionSD.self, CartSD.self, ProductsSD.self,
        CardSD.self, TrackingSD.self,
    ])
}
