//
//  Chats.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 03/01/25.
//

import Foundation

struct ChatResponse: Decodable {
    let status: Bool
    let type: String?
    let id_chat: Int?
    let message: String?
}

struct SupportResponse: Decodable {
    let status: String
    let message: String
    let data: [SupportData]?
}

struct SupportData: Decodable {
    let cc_id: Int
    let cc_userApp_id: String?
    let cc_credential_id: String?
    let cc_type_support_id: String
    let cc_status_id: String
    let created_at: String?
    let updated_at: String?
    let close_at: String?
}

struct MessagesResponse: Decodable {
    let status: String
    let message: String
    let data: [MessagesData]?
}

struct MessagesData: Decodable {
    let mc_id: Int
    let mc_chats_clients_id: String
    let mc_message: String
    let mc_user: String
    let mc_time_at: String
    let created_at: String?
    let updated_at: String?
}

// Chat orders

struct OrderChatResponse: Decodable {
    let status: String
    let message: String
    let data: OrderChatData?
}

struct OrderChatData: Decodable {
    let id_chat: Int
    let messages: [MessagesData]
}
