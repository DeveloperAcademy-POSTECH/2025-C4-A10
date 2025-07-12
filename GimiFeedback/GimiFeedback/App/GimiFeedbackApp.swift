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
    
    init() {
        KakaoSDK.initSDK(appKey: Bundle.kakaoNativeAppKey)
    }
    
    var body: some Scene {
        WindowGroup {
            OnboardingStartView()
                .onOpenURL { url in
                    if AuthApi.isKakaoTalkLoginUrl(url) {
                        _ = AuthController.handleOpenUrl(url: url)
                    }
                }
        }
    }
}
