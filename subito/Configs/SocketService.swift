//
//  SocketService.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 24/12/24.
//

import Foundation
import SocketIO

final class SocketService: ObservableObject {
    let socketManager: SocketManager = SocketManager(socketURL: URL(string: "https://qa-dev-pw.mx:5001")!, config: [.log(false), .compress, .reconnects(true), .forceWebsockets(true)])
    
    @Published var socket: SocketIOClient
    @Published var response: String = ""
    @Published var data: Any?
    static var socketClient: SocketService = SocketService()
    
    init () {
        socket = socketManager.defaultSocket
        connect_socket()
    }
    
    func connect_socket () {
        if String("\(socket.status)") != "connected" {
            socket.connect()
            socket.on(clientEvent: .connect){ data, ack in
                print(data, ack)
            }
        }
        
        socket.on(clientEvent: .disconnect) { data, ack in
            print(data, ack)
        }
    }
    
    func disconnect_socket(){
        socket.disconnect()
        socket.on(clientEvent: .disconnect) { data, ack in
            print("Disconnect from server")
        }
    }
    
    func clearListener(listener: String) {
        socket.off(listener)
    }
}
