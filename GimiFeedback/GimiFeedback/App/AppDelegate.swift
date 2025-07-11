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
        
        return true
    }
}
