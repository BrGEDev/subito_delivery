//
//  ApiCaller.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 09/09/24.
//

import Foundation

final class ApiCaller: ObservableObject {
    
    func mercagoPago<T:Decodable>(url: String, method: String, body: [String:Any] = [:], ofType type: T.Type, _ completion: @escaping (T?, Bool) -> Void) {
        let urlfetch = URL(string: "https://api.mercadopago.com/v1/\(url)?public_key=TEST-4099973f-8403-4c13-8252-5bb42032987e")!
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
        let urlfetch = URL(string: "https://qa-dev-pw.mx/api/delivery-drive/" + url)!
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
