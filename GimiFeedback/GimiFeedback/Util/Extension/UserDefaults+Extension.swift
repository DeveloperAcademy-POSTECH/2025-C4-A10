//
//  UserDefaults+Extension.swift
//  GimiFeedback
//
//  Created by 승찬 on 7/26/25.
//

import Foundation

extension UserDefaults {
    enum Key: String {
        case guideToast
        case channelGuideToast
    }

    /// 값을 저장
    func save(_ value: Any, for key: Key) {
        set(value, forKey: key.rawValue)
    }

    /// Bool 값 저장 (자주 쓰이므로 오버로드)
    func save(_ boolValue: Bool, for key: Key) {
        set(boolValue, forKey: key.rawValue)
    }

    /// 값 불러오기
    func value(for key: Key) -> Any? {
        object(forKey: key.rawValue)
    }

    /// Bool 값 불러오기
    func bool(for key: Key) -> Bool {
        bool(forKey: key.rawValue)
    }

    /// 값 삭제
    func remove(_ key: Key) {
        removeObject(forKey: key.rawValue)
    }
}
