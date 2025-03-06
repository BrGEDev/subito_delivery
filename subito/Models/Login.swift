//
//  Login.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 09/09/24.
//

import Foundation

struct Login: Codable {
    let status: String
    let data: LoginData?
    let message: String
}

struct LoginData: Codable{
    let user: LoginInfo?
    let token: String
}

struct LoginInfo: Codable{
    let ua_id: Int
    let ua_name: String
    let ua_lastname: String
    let ua_birthday: String?
    let ua_email: String
    let ua_phone: String?
    let ua_user_payment: String?
}

// Cierre de sesión

struct LogoutResponse: Decodable {
    let status: String
    let message: String
}

// Modelos de registro

struct RegisterResponse: Decodable {
    let status: String
    let message: String
    let data: RegisterData?
}

struct RegisterData: Decodable {
    let user: UserData?
    let name: [String]?
    let lastname:  [String]?
    let birthday:  [String]?
    let ua_email:  [String]?
    let password:  [String]?
    let ua_phone:  [String]?
}

struct UserData: Decodable {
    let ua_name: String
    let ua_lastname: String
    let ua_birthday: String
    let ua_email: String
    let ua_token: String
    let ua_phone: String?
}

struct RecoverResponse: Decodable {
    let status: String
    let message: String
}
