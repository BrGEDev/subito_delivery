//
//  subitoApp.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 09/09/24.
//

import SwiftUI
import SwiftData

@main
struct subitoApp: App {
    @StateObject var userState = UserStateModel()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
   
    var body: some Scene {
        WindowGroup {
            NavigationView{
                AppSwitch()
            }
            .environmentObject(userState)
        }
        .modelContainer(userState.container)
    }
}
