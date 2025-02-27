//
//  ApiCaller.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 09/09/24.
//

import Foundation

final class ApiCaller: ObservableObject {
    
    func mercagoPago<T:Decodable>(url: String, method: String, body: [String:Any] = [:], ofType type: T.Type, _ completion: @escaping (T?, Bool) -> Void) {
        let urlfetch = URL(string: "https://api.mercadopago.com/v1/\(url)?public_key=APP_USR-8daeda8b-e726-406d-8c0a-c9ca1f236baa")!
        var request = URLRequest(url: urlfetch)
        
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if method != "GET" {
            let bodyRequest = try! JSONSerialization.data(withJSONObject: body, options: [])
            request.httpBody = bodyRequest
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                DispatchQueue.main.async {
                    do {
                        let model = try JSONDecoder().decode(T.self, from: data)
                        completion(model, true)
                    } catch {
                        print(error, data)
                        completion(nil, false)
                    }
                }
            }
        }.resume()
    }
    
    func fetch<T:Decodable>(url: String, method: String, body: [String:Any] = [:], token: String = "", ofType type: T.Type, _ completion: @escaping (T?, Bool) -> Void){
        let urlfetch = URL(string: "https://ti-lexa.tech/api/delivery-drive/" + url)!
        var request = URLRequest(url: urlfetch)
        
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        if method != "GET" {
            let bodyRequest = try! JSONSerialization.data(withJSONObject: body, options: [])
            request.httpBody = bodyRequest
        }
       
        URLSession.shared.dataTask(with: request){ data, response, error in
            
            if let data = data {
                DispatchQueue.main.async {
                    do {
                        let model = try JSONDecoder().decode(T.self, from: data)
                        completion(model, true)
                    } catch{
                        print(error)
                        completion(nil, false)
                    }
                }
                
            }
            
        }.resume()
    }
}
