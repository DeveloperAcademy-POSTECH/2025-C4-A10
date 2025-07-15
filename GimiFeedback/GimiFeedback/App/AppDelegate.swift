//
//  Appdelegate.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/9/25.
//

import SwiftUI
import FirebaseCore

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        setBackButtonColor()
        
        return true
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
