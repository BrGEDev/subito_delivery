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
    
}
