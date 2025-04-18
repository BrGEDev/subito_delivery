//
//  ChatExtension.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 03/01/25.
//

import Foundation
import SwiftData
import SwiftUI

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
                    ? (messages[Int(index)! + 1].isCurrentUser
                        != message.isCurrentUser
                        ? true : false)
                    : true)
                : messages.count > Int(index)! + 1
                    ? (messages[Int(index)! + 1].isCurrentUser
                        == message.isCurrentUser ? false : true) : true)
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
            ) { res, status in
                if status {
                    if res!.status == true {
                        let calendar = Date()
                        let date = calendar.formatted(
                            date: .omitted, time: .shortened)

                        listenMessages()

                        id_chat = res!.id_chat
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

            break
        case .join(let id):

            id_chat = id

            api.fetch(
                url: "client_chat/get/\(id)", method: "GET", token: user.token,
                ofType: MessagesResponse.self
            ) { res, status in
                listenMessages()
                if status {
                    if res!.data != nil {
                        res!.data!.forEach { message in
                            messages.append(
                                Message(
                                    content: message.mc_message,
                                    time: message.mc_time_at,
                                    isCurrentUser: message.mc_user
                                        == "\(user.name) \(user.lastName)"
                                )
                            )
                        }
                    }
                }
            }

            break
        case .joinWithDelivery(let id):

            api.fetch(
                url: "chat_order",
                method: "POST",
                body: ["order_id": id, "id_user": user.id],
                ofType: OrderChatResponse.self
            ) { res, status in
                listenMessages()
                if status {
                    if res!.data != nil {
                        id_chat = res!.data!.id_chat

                        res!.data!.messages.forEach { message in
                            messages.append(
                                Message(
                                    content: message.mc_message,
                                    time: message.mc_time_at,
                                    isCurrentUser: message.mc_user
                                        == "\(user.name) \(user.lastName)"
                                )
                            )
                        }
                    }
                }
            }

            break
        }
    }

    func sendMessage() {
        let user = try! context.fetch(FetchDescriptor<UserSD>()).first!

        if !newMessage.isEmpty {
            let calendar = Date()
            let date = calendar.formatted(date: .omitted, time: .shortened)

            var event = "new message"
            switch options {
            case .joinWithDelivery(_):
                  event =  "message orders"
                break

            default:
                event = "new message"
                break
            }

            socket.socket.emit(event, newMessage, "\(user.name) \(user.lastName)", date, id_chat ?? 0, "client", 3, "txt")

            messages.append(
                Message(
                    content: newMessage, time: date, isCurrentUser: true))
            newMessage = ""

        }
    }

    func listenMessages() {
        let user = try! context.fetch(FetchDescriptor<UserSD>()).first!
        
        var event = "new message"
        switch options {
        case .joinWithDelivery(_):
              event =  "message orders"
            break

        default:
            event = "new message"
            break
        }
        
        socket.socket.on(event) { data, ack in
            print(event)
            
            if id_chat != nil {
                if id_chat == Int("\(data[3])") {
                    if data[1] as! String != "\(user.name) \(user.lastName)"
                    {
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

        chats = []
        api.fetch(
            url: "chatsActive", method: "GET", token: token,
            ofType: SupportResponse.self
        ) { res, status in
            if status {
                if res!.status == "success" {
                    chats = res!.data!
                }
            }
        }
    }
}
