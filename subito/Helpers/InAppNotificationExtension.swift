//
//  InAppNotificationExtension.swift
//  InAppNotificationExample
//
//  Created by Brandon Guerra Espinoza  on 10/03/25.
//

import SwiftUI
import AVFoundation

extension UIApplication {
    func inAppNotification<Content: View>(
        timeout: CGFloat = 5,
        swipeToClose: Bool = true,
        playSound: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) {
        if let activeWindow =
            (UIApplication.shared.connectedScenes.first as? UIWindowScene)?
            .windows.first(where: { $0.tag == 0320 })
        {
            let frame = activeWindow.frame
            let safeArea = activeWindow.safeAreaInsets

            var tag: Int = 1009
            let checkForDynamicIsland = safeArea.top >= 51

            if let previousTag = UserDefaults.standard.value(
                forKey: "in_app_notification_tag") as? Int
            {
                tag = previousTag + 1
            }

            UserDefaults.standard.setValue(
                tag, forKey: "in_app_notification_tag")
            
            if checkForDynamicIsland {
                if let controller = activeWindow.rootViewController as? StatusBarBasedController {
                    controller.statusBarHidden = true
                    controller.setNeedsStatusBarAppearanceUpdate()
                }
            }

            let config = UIHostingConfiguration {
                AnimatedNotificationView(
                    content: content(),
                    safeArea: safeArea,
                    tag: tag,
                    adaptForDynamicIsland: checkForDynamicIsland,
                    timeout: timeout,
                    swipeToClose: swipeToClose,
                    playSound: playSound
                )
                .frame(
                    width: frame.width - (checkForDynamicIsland ? 20 : 30),
                    height: 120, alignment: .top
                )
                .contentShape(.rect)
            }

            let view = config.makeContentView()
            view.backgroundColor = UIColor.clear
            view.translatesAutoresizingMaskIntoConstraints = false
            
            if let rootView = activeWindow.rootViewController?.view {
                rootView.addSubview(view)

                view.centerXAnchor.constraint(equalTo: rootView.centerXAnchor)
                    .isActive = true
                view.tag = tag
                view.centerYAnchor.constraint(
                    equalTo: rootView.centerYAnchor,
                    constant: (-(frame.height - safeArea.top) / 2)
                        + (checkForDynamicIsland ? 11 : safeArea.top)
                ).isActive = true
            }
        }
    }
}

private struct AnimatedNotificationView<Content: View>: View {

    let content: Content
    let safeArea: UIEdgeInsets
    let tag: Int
    let adaptForDynamicIsland: Bool
    let timeout: CGFloat
    let swipeToClose: Bool
    let playSound: Bool
    
    let systemSoundID: SystemSoundID = 1312

    @State private var animatedNotification: Bool = false

    var body: some View {
        content
            .blur(radius: animatedNotification ? 0 : 10)
            .disabled(!animatedNotification)
            .mask {
                if adaptForDynamicIsland {
                    RoundedRectangle(cornerRadius: 50, style: .continuous)
                } else {
                    Rectangle()
                }
            }
            .scaleEffect(
                adaptForDynamicIsland ? (animatedNotification ? 1 : 0.01) : 1,
                anchor: .init(x: 0.5, y: 0.01)
            )
            .offset(y: offSetY)
            .gesture (
                DragGesture()
                    .onEnded({ value in
                        if -value.translation.height > 50 && swipeToClose {
                            withAnimation(
                                .smooth, completionCriteria: .logicallyComplete
                            ) {
                                animatedNotification = false
                            } completion: {
                                removeNotificationFromWindow()
                            }
                        }
                    })
            )
            .onAppear(perform: {
                Task {
                    guard !animatedNotification else { return }

                    if playSound {
                        AudioServicesPlaySystemSound(systemSoundID)
                    }
                    
                    withAnimation(.smooth) {
                        animatedNotification = true
                    }

                    try await Task.sleep(
                        for: .seconds(timeout < 1 ? 1 : timeout))

                    guard animatedNotification else { return }

                    withAnimation(
                        .smooth, completionCriteria: .logicallyComplete
                    ) {
                        animatedNotification = false
                    } completion: {
                        removeNotificationFromWindow()
                    }

                }
            })
    }

    var offSetY: CGFloat {
        if adaptForDynamicIsland {
            return 0
        }

        return animatedNotification ? 20 : -(safeArea.top + 130)
    }

    func removeNotificationFromWindow() {
        if let activeWindow =
            (UIApplication.shared.connectedScenes.first as? UIWindowScene)?
            .windows.first(where: { $0.tag == 0320 })
        {
            if let view = activeWindow.viewWithTag(tag) {
                view.removeFromSuperview()
                
                if let controller = activeWindow.rootViewController as? StatusBarBasedController, controller.view.subviews.isEmpty {
                    controller.statusBarHidden = false
                    controller.setNeedsStatusBarAppearanceUpdate()
                }
            }
        }
    }
}
