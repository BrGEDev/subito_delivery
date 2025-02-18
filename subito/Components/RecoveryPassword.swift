//
//  RecoveryPassword.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 18/02/25.
//

import SwiftUI

struct RecoveryPassword: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    @StateObject var api: ApiCaller = ApiCaller()

    @State var correo: String = ""
    @State var alert: Bool = false
    @State var message: String = ""
    @State var title: String = ""

    var body: some View {
        NavigationView {
            VStack {
                VStack(alignment: .center, spacing: 40) {
                    Text(
                        "Ingresa tu correo electrónico para restablecer tu contraseña"
                    )
                    .multilineTextAlignment(.center)

                    TextField("Correo electrónico", text: $correo)
                        .multilineTextAlignment(.center)
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: 50)
                        .background(
                            colorScheme == .dark
                                ? Color.white.opacity(0.1).cornerRadius(20)
                                : Color.black.opacity(0.06).cornerRadius(20))


                    VStack {
                        Button(action: {
                            forgotPassword()
                        }) {
                            Text("Continuar")
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
                .alert(isPresented: $alert) {
                    Alert(
                        title: Text(title).bold(),
                        message: Text(message),
                        dismissButton: .default(Text("Aceptar")) {
                            if title == "¡Listo!" {
                                dismiss()
                            }
                        }
                    )
                }
            }
            .navigationTitle("Recuperar contraseña")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func forgotPassword() {
        if correo != "" || !correo.isEmpty {
            api.fetch(
                url: "recover_password", method: "POST",
                body: ["email": correo], ofType: RecoverResponse.self
            ) { res in
                if res.status == "success" {
                    alert = true
                    title = "¡Listo!"
                    message = "Revisa tu correo electrónico y sigue las instrucciones para continuar."
                } else {
                    alert = true
                    title = "Error"
                    message = "Esta cuenta no existe, verifica tu correo electrónico e intenta nuevamente."
                }
            }
        } else {
            alert = true
            title = "Error"
            message = "Debe ingresar un correo electrónico."
        }
    }
}
