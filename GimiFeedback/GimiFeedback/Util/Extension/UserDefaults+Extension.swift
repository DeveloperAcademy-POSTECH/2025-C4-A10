//
//  UserDefaults+Extension.swift
//  GimiFeedback
//
//  Created by 승찬 on 7/26/25.
//

import Foundation

extension UserDefaults {
    private enum Key {
        static let guideToast = "guideToast"
    }
    
    func saveGuideToast() {
        set(true, forKey: Key.guideToast)
    }

    /// 토스트를 보여준 적이 있는지 확인
    var isShowGuideToast: Bool {
        bool(forKey: Key.guideToast)
    }
    
    func removeGuideToast() {
        removeObject(forKey: Key.guideToast)
    }
}
