//
//  Register.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 10/12/24.
//

import SwiftUI

struct Register: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject var api: ApiCaller = ApiCaller()
    
    @State var name: String = ""
    @State var lastName: String = ""
    @State var email: String = ""
    @State var birthday: Date = Date()
    @State var password: String = ""
    
    @State var alert: Bool = false
    @State var errorMessage: String = ""
    @State var title: String = ""
    
    var body: some View {
        NavigationView{
            VStack {
                
                Form {
                    
                    VStack{
                        Image(.apprisaBlack)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200)
                            .padding(5)
                    }
                    .padding(.top, 35)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowBackground(Color.white.opacity(0))
                    
                    Section{
                        TextField("Nombre", text: $name)
                            .padding()
                            .frame(height: 50)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        
                        TextField("Apellido(s)", text: $lastName)
                            .padding()
                            .frame(height: 50)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        
                        DatePicker("Fecha de nacimiento", selection: $birthday, displayedComponents: [.date])
                            .datePickerStyle(.compact)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        
                        TextField("Correo", text: $email)
                            .padding()
                            .frame(height: 50)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        
                        SecureField("Contraseña", text: $password)
                            .padding()
                            .frame(height: 50)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    .listRowBackground(Color.white.opacity(0))
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                    
                    VStack{
                        Button(action: {
                            register()
                        }){
                            Text("Registrarme")
                        }
                        .foregroundColor(.black)
                        .frame(width: 200, height: 50)
                        .background(Color.yellow)
                        .cornerRadius(20)
                        .padding()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowBackground(Color.white.opacity(0))
                }
                .alert(isPresented: $alert){
                    Alert(title: Text(title).bold(),
                          message: Text(errorMessage),
                          dismissButton: .default(Text("Aceptar")){
                        if title == "¡Listo!"{
                            dismiss()
                        }
                    }
                    )
                }
                .onSubmit {
                    register()
                }
            }
            .navigationTitle("¡Bienvenido!")
            .scrollContentBackground(.hidden)
        }
    }
}
