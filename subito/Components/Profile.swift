//
//  Profile.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 06/01/25.
//

import SwiftUI
import SwiftData

struct Profile: View {
   
    @Environment(\.modelContext) var modelContext
    @StateObject var api: ApiCaller = .init()
    
    @Query var query: [UserSD]
    var user: UserSD? { query.first }
    
    @State var name: String = ""
    @State var lastName: String = ""
    @State var birthDate: Date = Date()
    @State var phone: String = ""
    @State var email: String = ""
    
    @State private var titleAlert: String = ""
    @State private var description: String = ""
    @State private var alert: Bool = false
    
    var body: some View {
        VStack{
            Form {
                Section(header: Text("Datos personales")){
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
                    
                    DatePicker("Fecha de nacimiento", selection: $birthDate, displayedComponents: [.date])
                        .datePickerStyle(.compact)
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                
                Section(header: Text("Contacto")){
                    TextField("Teléfono", text: $phone)
                        .keyboardType(.numberPad)
                        .padding()
                        .frame(height: 50)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    TextField("Correo electrónico", text: $email)
                        .padding()
                        .frame(height: 50)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                
            }
            .navigationTitle("Mi perfil")
            .scrollContentBackground(.hidden)
            .onSubmit {
                validateForm()
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction){
                    Button("Aceptar"){
                        validateForm()
                    }
                }
            }
            .alert(isPresented: $alert){
                Alert(title: Text(titleAlert), message: Text(description), dismissButton: .default(Text("Aceptar")))
            }
        }
        .onAppear {
            loadUser()
        }
    }
    
    private func loadUser(){
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_MX")
        formatter.dateFormat = "yyyy-MM-dd"
        //let date = formatter.date(from: user!.birthday)!
        
        name = user!.name
        lastName = user!.lastName
        //birthDate = date
        email = user!.email
        phone = user!.phone ?? ""
    }
    
    private func validateForm() {
        guard !name.isEmpty else {
            showAlert(title: "Error", message: "Ingrese su nombre")
            return
        }
        
        guard !lastName.isEmpty else {
            showAlert(title: "Error", message: "Ingrese su apellido")
            return
        }
        
        guard !email.isEmpty else {
            showAlert(title: "Error", message: "Ingrese su correo")
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let birthday = formatter.string(from: birthDate)
        
        let data: [String:Any] = [
            "name" : name,
            "lastname" : lastName,
            "email" : email,
            "birthday" : birthday,
            "phone" : phone as Any
        ]
        
        api.fetch(url: "profile/update", method: "POST", body: data, token: user!.token, ofType: ProfileResponse.self) { res, status in
            if status {
                if res!.status == "success" {
                    showAlert(title: "Datos guardados", message: "Se actualizaron los datos correctamente")
                    
                    user!.lastName = lastName
                    user!.name = name
                    user!.email = email
                    user!.birthday = birthday
                    user!.phone = phone
                } else {
                    showAlert(title: "Error", message: "No se pudo actualizar los datos, intente más tarde.")
                }
            } else {
                showAlert(title: "Error", message: "No se pudo actualizar los datos, intente más tarde.")
            }
        }
    }
    
    private func showAlert(title: String, message: String){
        titleAlert = title
        description = message
        alert = true
    }
}
