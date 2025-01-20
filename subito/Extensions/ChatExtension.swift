//
//  ChatExtension.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 03/01/25.
//

import Foundation
import SwiftUI
import SwiftData

extension Chat {
    
    func calcVisibility(index: String, message: Message) -> Bool {
        return Int(index)! > 0
        ? (messages.count > Int(index)! + 1
           && messages[Int(index)! + 1]
            .isCurrentUser
           == message.isCurrentUser
           ? false : true)
        : (Int(index)! == 0 && !message.isCurrentUser
           ? (messages.count > Int(index)! + 1
              ? (messages[Int(index)! + 1].isCurrentUser != message.isCurrentUser
                 ? true : false)
              : true)
           : false)
    }

    func getMessages() {
        let user = try! context.fetch(FetchDescriptor<UserSD>()).first!

        switch options {
        case .create(let support):
            let data: [String: Any] = [
                "type_support": support,
                "id_user": user.id,
            ]

            api.fetch(
                url: "new_chat", method: "POST", body: data, token: user.token,
                ofType: ChatResponse.self
            ) { res in
                if res.status == true {
                    let calendar = Date()
                    let date = calendar.formatted(date: .omitted, time: .shortened)
                    
                    listenMessages()
                    
                    id_chat = res.id_chat
                    messages.append(
                        Message(
                            content:
                                "Bienvenido al chat de \(title.lowercased()). En breve, uno de nuestros agentes se contactará con usted. Por favor, escriba su pregunta o consulta.",
                            time: date,
                            isCurrentUser: false
                        )
                    )
                }
            }

        case .join(let id):
            let data: [String: Any] = [
                "id_chat": id
            ]

            listenMessages()

            if messages.isEmpty {
                let calendar = Date()
                let date = calendar.formatted(date: .omitted, time: .shortened)
                
                messages.append(
                    Message(
                        content:
                            "Bienvenido al chat de \(title.lowercased()). En breve, uno de nuestros agentes se contactará con usted. Por favor, escriba su pregunta o consulta.",
                        time: date,
                        isCurrentUser: false
                    )
                )
            }
        }
    }

    func sendMessage() {
        let user = try! context.fetch(FetchDescriptor<UserSD>()).first!
        
        if !newMessage.isEmpty {
            let calendar = Date()
            let date = calendar.formatted(date: .omitted, time: .shortened)
            
            socket.socket.emit("new message", newMessage, "\(user.name) \(user.lastName)", date, id_chat ?? 0, "client", 3, "txt")
            
            messages.append(Message(content: newMessage, time: date, isCurrentUser: true))
            newMessage = ""
        }
    }

    func listenMessages() {
        let user = try! context.fetch(FetchDescriptor<UserSD>()).first!
        
        socket.socket.on("new message") { data, ack in
            print(data)
            if id_chat != nil {
                if id_chat == Int("\(data[3])") {
                    if data[1] as! String != "\(user.name) \(user.lastName)" {
                        messages.append(
                            Message(
                                content: data[0] as! String,
                                time: data[2] as! String,
                                isCurrentUser: false
                            )
                        )
                    }
                }
            }
        }
    }
}

// Struct de la vista de soporte (previo a chat)

extension Support {
    func loadChats() {
        let query = FetchDescriptor<UserSD>()
        let token = try! context.fetch(query).first!.token
        
        api.fetch(url: "chatsActive", method: "GET", token: token, ofType: SupportResponse.self){ res in
            print(res)
            
            if res.status == "success" {
                
            }
        }
    }
}
