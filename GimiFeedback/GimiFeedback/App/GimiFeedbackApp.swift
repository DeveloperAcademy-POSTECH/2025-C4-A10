//
//  GimiFeedbackApp.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/8/25.
//

import SwiftUI
import FirebaseCore
import KakaoSDKCommon
import KakaoSDKAuth

@main
struct GimiFeedbackApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var userViewModel: UserViewModel
    @StateObject private var notificationRouter: NotificationViewModel
    
    init() {
        KakaoSDK.initSDK(appKey: Bundle.kakaoNativeAppKey)
        _userViewModel = StateObject(wrappedValue: UserViewModel())
        _notificationRouter = StateObject(wrappedValue: .init())
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if userViewModel.isLoggedIn {
                    MainView(notificationRouter: notificationRouter)
                        .onAppear {
                            if let userInfo = delegate.saveUserInfo {
                                notificationRouter.send(.saveUserInfo(userInfo: userInfo))
                            }
                        }
                } else {
                    StartView()
                        .onOpenURL { url in
                            if AuthApi.isKakaoTalkLoginUrl(url) {
                                _ = AuthController.handleOpenUrl(url: url)
                            }
                        }
                }
            }
            .environmentObject(userViewModel)
        }
    }
}
