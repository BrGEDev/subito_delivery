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
    @State private var overlayWindow: PassTroughtWindow?
   
    var body: some Scene {
        WindowGroup {
            NavigationView{
                AppSwitch()
            }
            .onAppear {
                if overlayWindow == nil {
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        let overlayWindow = PassTroughtWindow(windowScene: windowScene)
                        overlayWindow.backgroundColor = UIColor.clear
                        overlayWindow.tag = 0320
                        let controller = StatusBarBasedController()
                        controller.view.backgroundColor = UIColor.clear
                        overlayWindow.rootViewController = controller
                        overlayWindow.isHidden = false
                        overlayWindow.isUserInteractionEnabled = true
                        self.overlayWindow = overlayWindow
                    }
                }
            }
        }
        .modelContainer(userState.container)
        .environmentObject(userState)
    }
}

class StatusBarBasedController: UIViewController {
    var statusBarStyle: UIStatusBarStyle = .default
    var statusBarHidden: Bool = false
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }
    
    override var prefersStatusBarHidden: Bool {
        return statusBarHidden
    }
}

fileprivate class PassTroughtWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let view = super.hitTest(point, with: event) else {
            return nil
        }
        return rootViewController?.view == view ? nil : view
    }
}
