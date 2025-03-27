//
//  LoginExtension.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 10/12/24.
//

import SwiftUI

extension Register{
    func register(){
        guard name.isEmpty == false && lastName.isEmpty == false && email.isEmpty == false && password.isEmpty && phone.isEmpty == false else {
            alert = true
            title = "Atención"
            errorMessage = "Debe completar el formulario"
            return
        }
        
        guard phone.count > 10 else {
            alert = true
            title = "Atención"
            errorMessage = "Ingrese un número de teléfono válido a 10 dígitos"
            return
        }
        
        guard password.count >= 8 else {
            alert = true
            title = "Atención"
            errorMessage = "La contraseña debe tener mínimo 8 carácteres"
            return
        }
        
        withAnimation{
            loading = true
        }
        
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd"
//        let birthdate = formatter.string(from: birthday)

        let data = [
            "name" : name,
            "lastname" : lastName,
            "email" : email,
            "phone" : phone,
            "password" : password,
        ]
        
        api.fetch(url: "register", method: "POST", body: data, ofType: RegisterResponse.self){ res, status in
            withAnimation {
                loading = false
            }
            
            if status {
                if res!.status == "success" {
                    alert = true
                    title = "¡Listo!"
                    errorMessage = "Se completó el registro, ingresa a tu correo y sigue las instrucciones para verificar tu cuenta."
                } else {
                    alert = true
                    title = "Error"
                    errorMessage = res!.data?.ua_email?[0] ?? "Ya tiene una cuenta registrada con ese correo, inicie sesión o ingresa otro correo"
                }
            } else {
                alert = true
                title = "Error"
                errorMessage = "Ocurrió un error de conexión, intente más tarde."
            }
        }
    }
}
