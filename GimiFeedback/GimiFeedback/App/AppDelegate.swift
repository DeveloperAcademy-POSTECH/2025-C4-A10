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
    var saveUserInfo: [AnyHashable: Any]?
    
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
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        print("APNS token: \(deviceToken)")
        Messaging.messaging().apnsToken = deviceToken
    }
    
    // Foreground(앱 켜진 상태)에서도 알림 오는 설정
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.badge, .list, .banner, .sound])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        handlePushNotification(userInfo: userInfo)
        completionHandler()
    }
}

extension AppDelegate: MessagingDelegate {
    
    // 파이어베이스 MessagingDelegate 설정
    func messaging(
        _ messaging: Messaging,
        didReceiveRegistrationToken fcmToken: String?
    ) {
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
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
    
    private func handlePushNotification(userInfo: [AnyHashable: Any]) {
        guard let type = userInfo["type"] as? String,
              type == "feedback",
              let feedbackId = userInfo["feedbackId"] as? String else { return }
        
        saveUserInfo = ["destination": "feedbackDetail", "feedbackId": feedbackId]
        
        NotificationCenter.default.post(
            name: Notification.Name("PushNavigation"),
            object: nil,
            userInfo: ["destination": "feedbackDetail", "feedbackId": feedbackId]
        )
    }
}
