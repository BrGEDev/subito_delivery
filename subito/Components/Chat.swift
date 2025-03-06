//
//  Chat.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 03/01/25.
//

import SwiftData
import SwiftUI

enum ChatOptions: Hashable, Equatable {
    case create(support: Int)
    case join(id: Int)
}

struct Message: Hashable, Identifiable {
    var id: UUID = UUID()
    var content: String
    var time: String
    var isCurrentUser: Bool
}

struct MessageStruct: View {
    @Environment(\.colorScheme)var colorScheme
    
    var content: String
    var isCurrent: Bool
    
    var body: some View {
        Text(content)
            .padding(15)
            .foregroundStyle(Color.black)
            .background(
                isCurrent ? Color.accentColor : Color(colorScheme == .dark ? UIColor.systemGray2 : UIColor.systemGray6)
            )
            .cornerRadius(25)
    }
}

struct MessageView: View {
    @Environment(\.colorScheme)var colorScheme
    
    var message: Message
    var visibleImage: Bool = true

    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            if !message.isCurrentUser {
                if visibleImage {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 30, height: 30)
                        .clipShape(Circle())
                        .clipped()
                        .foregroundStyle(Color(colorScheme == .dark ? UIColor.systemGray : UIColor.systemGray5))
                } else {
                    Spacer()
                        .frame(width: 30, height: 30)
                }
            } else {
                Spacer()
            }
            
            VStack(alignment: message.isCurrentUser ? .trailing : .leading){
                MessageStruct(content: message.content, isCurrent: message.isCurrentUser)
                    .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 25))
                    .contextMenu {
                        Label((message.isCurrentUser ? "Enviado" : "Recibido") + ": \(message.time)", systemImage: "clock")
                    }
                
                if visibleImage {
                    Text(message.time)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding([.trailing, .leading])
    }
}

struct Chat: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) var context
    @StateObject var api: ApiCaller = ApiCaller()
    var socket = SocketService.socketClient

    var title: String
    var options: ChatOptions
    @State var newMessage: String = ""
    @State var messages: [Message] = []
    @State var id_chat: Int?

    var body: some View {
        VStack {
            ScrollView {
                ScrollViewReader { proxy in
                    ForEach(messages, id: \.self) { message in
                        let index: String = messages.firstIndex(where: {
                            $0.id == message.id
                        })!.description

                        if index != "" {
                            MessageView(
                                message: message,
                                visibleImage: calcVisibility(
                                    index: index, message: message)
                            )
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(
                                [.top],
                                Int(index)! > 0
                                    ? (messages[Int(index)! - 1]
                                        .isCurrentUser
                                        == message.isCurrentUser ? -5 : 20)
                                    : 0
                            )
                        }
                    }
                    .onAppear {
                        getMessages()

                        if !messages.isEmpty {
                            proxy.scrollTo(messages.last!)
                        }
                    }
                    .onChange(of: messages) {
                        if !messages.isEmpty {
                            withAnimation {
                                proxy.scrollTo(messages.last!, anchor: .bottom)
                            }
                        }
                    }
                    .onDisappear {
                        socket.clearListener(listener: "new message")
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(title)
        .safeAreaInset(edge: .bottom) {
            HStack {
                TextField("Mensaje", text: $newMessage)
                    .padding(10)
                    .background(Material.ultraThin)
                    .cornerRadius(30)

                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundStyle(Color.black)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.circle)
                .tint(Color.accentColor)
            }
            .padding(10)
            .background(Material.bar)
        }
    }
}
