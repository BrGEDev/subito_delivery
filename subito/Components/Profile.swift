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
    
    @State private var deleteAccount: Bool = false
    @State var code: String = ""
    @State var secondsRemaining = 0
    @EnvironmentObject var vm: UserStateModel
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    
    @State var loading: Bool = false
    
    var body: some View {
        VStack{
            Form {
                Group {
                    Section(header: Text("Datos personales")){
                        Group {
                            TextField("Nombre", text: $name)
                                
                            TextField("Apellido(s)", text: $lastName)
                            
                            DatePicker("Fecha de nacimiento", selection: $birthDate, displayedComponents: [.date])
                                .datePickerStyle(.compact)
                        }
                        .padding()
                        .frame(height: 50)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    
                    Section(header: Text("Contacto")){
                        Group {
                            TextField("Teléfono", text: $phone)
                                .keyboardType(.phonePad)
                            
                            TextField("Correo electrónico", text: $email)
                                .keyboardType(.emailAddress)
                        }
                        .padding()
                        .frame(height: 50)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    
                    Section(header: Text("Extras")){
                        Button(role: .destructive, action: {
                            deleteAccount = true
                            
                            Task {
                                await sendCode()
                            }
                        }){
                            Text("Eliminar mi cuenta")
                        }
                        .sheet(isPresented: $deleteAccount) {
                            NavigationView{
                                VStack{
                                    VStack(spacing: 40){
                                        Text("Ingresa el código de confirmación enviado a tu correo electrónico \(user!.email)")
                                        
                                        TextField("Código de confirmación", text: $code)
                                            .multilineTextAlignment(.center)
                                            .padding()
                                            .frame(maxWidth: .infinity, maxHeight: 50)
                                            .background(Material.bar)
                                            .cornerRadius(20)
                                            .keyboardType(.numberPad)
                                        
                                        HStack{
                                            if secondsRemaining == 0 {
                                                Text("¿No has recibido el código?")
                                                Button("Reenviar código") {
                                                    Task {
                                                        await resendCode()
                                                    }
                                                }
                                                .foregroundStyle(.blue)
                                                .disabled(secondsRemaining != 0)
                                            } else {
                                                Text("Podrás volver a intentarlo en \(secondsRemaining) segundos.")
                                            }
                                        }
                                        .font(.callout)

                                        VStack {
                                            Button(action: {
                                                deleteMyAccount()
                                            }) {
                                                Text("Verificar código")
                                            }
                                            .foregroundColor(.black)
                                            .frame(width: 200, height: 50)
                                            .background(Color.accentColor)
                                            .cornerRadius(20)
                                            .padding()
                                        }
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .listRowBackground(Color.white.opacity(0))
                                    }
                                    .padding()
                                    .alert(isPresented: $alert){
                                        Alert(title: Text(titleAlert), message: Text(description), dismissButton: .default(Text("Aceptar")))
                                    }
                                    .sheet(isPresented: $loading) {
                                        VStack {
                                            Image(.logo)
                                                .resizable()
                                                .frame(width: 90, height: 90)
                                                .scaledToFit()
                                                .rotationEffect(.degrees(rotation))
                                                .scaleEffect(1)
                                                .onAppear {
                                                    withAnimation(
                                                        Animation
                                                            .easeInOut(duration: 2)
                                                            .repeatForever(autoreverses: false)
                                                    ) {
                                                        rotation += 360
                                                    }
                                                }
                                            
                                            Text("Confirmando la eliminación...")
                                                .multilineTextAlignment(.center)
                                                .font(.title2)
                                                .foregroundStyle(.secondary)
                                                .padding()
                                        }
                                        .presentationDetents([.height(280)])
                                        .presentationBackgroundInteraction(.disabled)
                                        .interactiveDismissDisabled(true)
                                        .presentationCornerRadius(35)
                                    }
                                }
                                .toolbarTitleDisplayMode(.inline)
                                .navigationTitle("Eliminación de cuenta")
                            }
                            .presentationDetents([.medium])
                            .presentationCornerRadius(35)
                            .presentationDragIndicator(.visible)
                        }
                    }
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
        if !user!.birthday!.isEmpty {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "es_MX")
            formatter.dateFormat = "yyyy-MM-dd"
            let date = formatter.date(from: user!.birthday!)!
            
            birthDate = date
        }
        
        name = user!.name
        lastName = user!.lastName
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
    
    private func resendCode() async {
        await sendCode()
        
        withAnimation {
            secondsRemaining = 60
        }
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (Timer) in
            if secondsRemaining > 0 {
                withAnimation {
                    secondsRemaining -= 1
                }
            } else {
                Timer.invalidate()
            }
        }
    }
    
    public func sendCode() async {
        let response = try? await api.fetchAsync(url: "confirmationEmailCode", method: "POST", token: user!.token, ofType: GenericDelete.self)
        print(response?.message as Any)
    }
    
    private func deleteMyAccount() {
        loading = true
        
        api.fetch(url: "deleteAccount", method: "POST", body: ["code": code], token: user!.token, ofType: GenericDelete.self) { res, status in
            loading = false
            if status {
                if res!.status == "success" {
                    DispatchQueue.main.async {
                        self.showAlert(title: "Completado", message: "Su cuenta ha sido eliminada, en breve se cerrará la sesión de manera automática")
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            Task {
                                await vm.signOut()
                            }
                        }
                    }
                } else {
                    self.showAlert(title: "Error", message: "El código de verificación es inválido, intente nuevamente")
                }
            } else {
                self.showAlert(title: "Error", message: "No se pudo completar la acción, intente nuevamente")
            }
        }
    }
}
