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

struct SelectedType: Hashable {
    var id: Int
    var title: String
    var option: ChatOptions
}

struct Support: View {
    @Environment(\.modelContext) var context
    @State var isExpanded: Bool = false
    
    @StateObject var api: ApiCaller = ApiCaller()
    
    @State var path: NavigationPath = NavigationPath()
    @State var chats: [SupportData] = []
    
    var types: [TypeSupport] = [
        .init(id: 2, icon: "phone.arrow.up.right.fill", title: "Call center", description: "Problemas con un pedido, producto incompleto, etc."),
        .init(id: 3, icon: "banknote.fill", title: "Tesorería", description: "Problemas con los pagos, aclaración del cobro de servicio, etc."),
        .init(id: 1, icon: "iphone.gen3",title: "Soporte técnico", description: "Problemas con la aplicación, problemas con mi cuenta, etc."),
    ]
    
    
    var body: some View {
        ZStack(alignment: .bottomTrailing){
            
            if !chats.isEmpty {
                List(chats.sorted(by: { $0.cc_id > $1.cc_id }), id: \.cc_id) { chat in
                    let title = types.first(where: { $0.id == Int(chat.cc_type_support_id) })?.title ?? ""
                    NavigationLink(destination: Chat(title: title, options: .join(id: chat.cc_id))){
                        Label(title: {
                            VStack(alignment: .leading){
                                Text(title)
                                
                                Text(chat.cc_credential_id == nil ? "Pendiente" : "Ticket activo")
                                    .foregroundStyle(chat.cc_credential_id == nil ? Color.orange : Color.green)
                            }
                        }, icon: {
                            Image(systemName: types.first(where: { $0.id == Int(chat.cc_type_support_id)})?.icon ?? "questionmark")
                        })
                    }
                }
                .listStyle(.plain)
            } else {
                VStack{
                    Text("Aún no tienes tickets de soporte activos.\n Toca '+' para comenzar.")
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundStyle(Color.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            ZStack(alignment: .bottomTrailing) {
                NavigationLink(destination: Chat(title: "Call Center", options: .create(support: 2))){
                    HStack(alignment: .center){
                        Image(systemName: "plus")
                            .font(.system(size: 20))
                            .tint(Color.black)
                    }
                    .padding([.leading, .trailing], 22)
                }
                .frame(maxWidth: 74, maxHeight: 74)
                .background(Color.accentColor)
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .shadow(color: Color.black.opacity(0.15), radius: isExpanded ? 0 : 6)
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Centro de soporte")
        .scrollContentBackground(.hidden)
        .onAppear {
            loadChats()
        }
    }
}
