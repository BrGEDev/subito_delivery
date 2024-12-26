//
//  Notifications.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 24/12/24.
//

import Foundation
import UserNotifications
import SwiftUI

final class Notifications: NSObject, ObservableObject {
    private let notificationsCenter = UNUserNotificationCenter.current()
    
    func checkAuthorization() {
        notificationsCenter.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                self.notificationsCenter.requestAuthorization(options: [.badge, .sound, .alert]) { success, error in
                    if success {
                        print("Success")
                    }
                }
            case .denied:
                print("Denied")
            case .authorized:
                print("Authorized")
            case .provisional:
                print("Provisional")
            case .ephemeral:
                print("Ephemeral")
            @unknown default:
                print("Error")
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
                self.checkAuthorization()
            }
        }
    }
}
