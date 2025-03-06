//
//  Notifications.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 24/12/24.
//

import Foundation
import UserNotifications

@MainActor
final class Notifications {
    private(set) var hasPermission: Bool = false
    
    private let notificationsCenter = UNUserNotificationCenter.current()
    
    init() {
        Task {
            await checkAuthorization()
        }
    }
    
    func request() async {
        do {
            try await notificationsCenter.requestAuthorization(options: [.alert, .badge, .sound])
            await checkAuthorization()
        } catch {
            print(error)
        }
    }
    
    func checkAuthorization() async {
        let status = await notificationsCenter.notificationSettings()
        
        switch status.authorizationStatus {
        case .authorized, .ephemeral, .provisional:
            hasPermission = true
            default:
            hasPermission = false
            
            Task {
                await request()
            }
        }
    }
    
    func dispatchNotification(title: String, body: String){
        notificationsCenter.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                let content = UNMutableNotificationContent()
                content.title = title
                content.body = body
                content.sound = .default
                
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
                self.notificationsCenter.add(request)
                print("Dispatch notification!")
            } else {
                print("Can't dispatch notification!")
                print("Kono notification settings ni")
            }
        }
    }
}
