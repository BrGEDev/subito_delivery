//
//  LoginExtension.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 10/12/24.
//

import SwiftUI

extension Register{
    func register(){
        guard name.isEmpty == false && lastName.isEmpty == false && email.isEmpty == false && password.isEmpty == false else {
            alert = true
            title = "Atención"
            errorMessage = "Debe completar el formulario"
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let birthdate = formatter.string(from: birthday)

        let data = [
            "name" : name,
            "lastname" : lastName,
            "birthday" : birthdate,
            "email" : email,
            "password" : password,
        ]
        
        api.fetch(url: "register", method: "POST", body: data, ofType: RegisterResponse.self){ res in
            if res.status == "success" {
                alert = true
                title = "¡Listo!"
                errorMessage = "Se completó el registro, puedes iniciar sesión."
            } else {
                alert = true
                title = "Error"
                errorMessage = res.errors?.ua_email![0] ?? "No se pudo completar el registro"
            }
        }
    }
}
