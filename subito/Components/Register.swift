//
//  Register.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 10/12/24.
//

import SwiftUI
import Combine

struct Register: View {
    @Environment(\.dismiss) var dismiss

    @StateObject var api: ApiCaller = ApiCaller()

    @State var name: String = ""
    @State var lastName: String = ""
    @State var email: String = ""
    @State var birthday: Date = Date()
    @State var password: String = ""
    @State var phone: String = ""

    @State var alert: Bool = false
    @State var errorMessage: String = ""
    @State var title: String = ""

    @State var loading: Bool = false
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    @State var directionModal: Bool = false
    
    var body: some View {
        if loading {
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
                        
                        Text("Creando tu cuenta...")
                            .multilineTextAlignment(.center)
                            .font(.title2)
                            .foregroundStyle(.secondary)
                            .padding()
                    }

                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        } else {
            NavigationView {
                VStack {
                    
                    Form {
                        
                        VStack {
                            Image(.apprisaBlack)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 200)
                                .padding(5)
                        }
                        .padding(.top, 35)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowBackground(Color.white.opacity(0))
                        
                        Section {
                            TextField("Nombre", text: $name)
                                .padding()
                                .frame(height: 50)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .keyboardType(.alphabet)
                            
                            TextField("Apellido(s)", text: $lastName)
                                .padding()
                                .frame(height: 50)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .keyboardType(.alphabet)
                            
                            DatePicker(
                                "Fecha de nacimiento", selection: $birthday,
                                displayedComponents: [.date]
                            )
                            .datePickerStyle(.compact)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            
                            TextField("Correo", text: $email)
                                .padding()
                                .frame(height: 50)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .keyboardType(.emailAddress)
                            
                            TextField("Teléfono", text: $phone)
                                .padding()
                                .frame(height: 50)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .keyboardType(.phonePad)
                                .onReceive(Just(phone)) { _ in limitText(10) }
                            
                            SecureField("Contraseña", text: $password)
                                .padding()
                                .frame(height: 50)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                        .listRowBackground(Color.white.opacity(0))
                        .listRowSeparator(.hidden)
                        .listRowInsets(
                            EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)
                        )
                    }
                    .alert(isPresented: $alert) {
                        Alert(
                            title: Text(title).bold(),
                            message: Text(errorMessage),
                            dismissButton: .default(Text("Aceptar")) {
                                if title == "¡Listo!" {
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
                .safeAreaInset(edge: .bottom) {
                    VStack {
                        Button(action: {
                            register()
                        }) {
                            Text("Registrarme")
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, maxHeight: 50, alignment: .center)
                        .background(Color.yellow)
                        .cornerRadius(20)
                        .padding()
                    }
                }
            }
        }
    }
    
    private func limitText(_ upper: Int) {
        if phone.count > upper {
            phone = String(phone.prefix(upper))
        }
    }
}
