//
//  LoginView.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 09/09/24.
//

import SwiftUI


struct PrincipalView: View{
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var vm: UserStateModel
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    @State var directionModal: Bool = false
    
    
    @State private var username = ""
    @State private var password = ""
    
    @FocusState private var usernameFocus: Bool
    
    @State private var showLogin: Bool = false
    @State private var alert: Bool = false
    @State private var message: String = ""
    
    @State private var opacity: Double = 0
    @State private var forgotPassword = false
    @State private var register: Bool = false
    
    var body: some View {
        if vm.isBusy {
            ZStack {
                Image(.fondo2)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()

                VStack {
                    
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
                        
                        Text("Iniciando sesión...")
                            .multilineTextAlignment(.center)
                            .font(.title2)
                            .foregroundStyle(.secondary)
                            .padding()
                    }

                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .navigationBarBackButtonHidden(vm.isBusy)
            }
        } else {
            ZStack{
                Image(.pedidos)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 1000, height: 1000)
                    .blur(radius: 20)
                    .ignoresSafeArea()
                
                VStack{
                    Image(.logoDark)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200)
                        .padding(40)
                        .zIndex(2)
                    
                    
                    VStack(spacing: 20){
                        
                        VStack{
                            Text("Iniciar Sesión")
                                .font(.title)
                                .bold()
                                .padding(EdgeInsets(top: 10, leading: 0, bottom: 30, trailing: 0))
                            
                            
                            Group{
                                TextField("Correo electrónico", text: $username)
                                    .keyboardType(.emailAddress)
                                
                                SecureField("Contraseña", text: $password)
                                    .onTapGesture {
                                        vm.alert = false
                                    }
                            }
                            .multilineTextAlignment(.center)
                            .padding()
                            .focused($usernameFocus)
                            .frame(width: 300, height: 50)
                            .background(
                                colorScheme == .dark ? Color.white.opacity(0.1).cornerRadius(20) : Color.black.opacity(0.06).cornerRadius(20)
                            )
                            
                            if vm.alert {
                                Text(vm.message).foregroundColor(.red).font(.footnote)
                            }
                            
                            Button(action: {
                                if username == "" || password == "" {
                                    alert = true
                                    message = "Debe ingresar su usuario y contraseña"
                                } else {
                                    Task {
                                        await vm.signIn(user: username, pass: password)
                                    }
                                }
                            }){
                                Text("Iniciar Sesión")
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                            .foregroundColor(.black)
                            .background(Color.accentColor)
                            .cornerRadius(20)
                            .frame(width: 200, height: 50)
                            .padding()
                            .disabled(password.count < 8 && username.isEmpty)
                        }
                        
                        HStack(alignment: .center, spacing: 40){
                            Button("Registrarme"){
                                register = true
                            }
                            .foregroundColor(.blue)
                            .font(.system(size: 16))
                            
                            Button("Olvidé mi contraseña"){
                                forgotPassword = true
                            }
                            .foregroundColor(.red)
                            .font(.system(size: 16))
                        }
                    }
                    .padding(30)
                    .background(colorScheme == .dark ? Color.black.opacity(0.89) : Color.white.opacity(0.89))
                    .clipShape(RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/))
                    .shadow(radius: 20)
                }
            }
            .onTapGesture {
                if usernameFocus {
                    usernameFocus = false
                }
            }
            .alert(isPresented: $alert){
                Alert(title: Text("Validación").bold(),
                      message: Text(message),
                      dismissButton: .default(Text("Aceptar"))
                )
            }
            .sheet(isPresented: $register){
                Register()
            }
            .sheet(isPresented: $forgotPassword) {
                RecoveryPassword()
                    .presentationDetents([.medium])
                    .presentationCornerRadius(35)
            }
        }
    }
}
