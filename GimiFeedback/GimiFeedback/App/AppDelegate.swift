//
//  Appdelegate.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/9/25.
//

import SwiftUI
import FirebaseCore
import UserNotifications
import FirebaseMessaging

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        setBackButtonColor()
        
        // 앱 실행 시 사용자에게 알림 허용 권한을 받음
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound] // 필요한 알림 권한을 설정
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )
        
        // UNUserNotificationCenterDelegate를 구현한 메서드를 실행시킴
        application.registerForRemoteNotifications()
        
        // 파이어베이스 Meesaging 설정
        Messaging.messaging().delegate = self
        
        return true
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // 백그라운드에서 푸시 알림을 탭했을 때 실행
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNS token: \(deviceToken)")
        Messaging.messaging().apnsToken = deviceToken
    }
    
    // Foreground(앱 켜진 상태)에서도 알림 오는 설정
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.list, .banner])
    }
}

extension AppDelegate: MessagingDelegate {
    
    // 파이어베이스 MessagingDelegate 설정
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("FCM 등록 토큰: \(String(describing: fcmToken))")
        
        saveToken()
        
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
    }
    
    func saveToken() {
        Messaging.messaging().token { token, error in
            if error != nil {
                print("토큰 가져오기 실패 : \(error?.localizedDescription ?? "")")
                return
            } else if let token = token {
                let newToken = Token(fcmToken: token, badgeCount: 0)
                if FirebaseAuthManager.currentUser {
                    
                    Task {
                        do {
                            let savedToken = try await FirestoreManager.shared.create(newToken)
                            print(savedToken)
                        } catch {
                            print("Token 저장 에러")
                        }
                    }
                    
                }
            }
        }
    }
}

extension AppDelegate {
    /// 백버튼 기본 설정
    /// apperance: NavigationBar의 기본 설정
    /// BarButtonItem: BarButtonItem의 기본 설정
    /// 뒤로가기 clear, Button Color black으로
    private func setBackButtonColor() {
        let backButtonAppearance = UIBarButtonItemAppearance()
        let appearance = UINavigationBarAppearance()
        
        backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
        //        appearance.configureWithOpaqueBackground()
        appearance.backButtonAppearance = backButtonAppearance
        appearance.configureWithTransparentBackground()
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UIBarButtonItem.appearance().tintColor = UIColor(.black)
    }
}
