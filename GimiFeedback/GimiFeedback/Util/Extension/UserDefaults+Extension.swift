//
//  UserDefaults+Extension.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/23/25.
//

import Foundation

extension UserDefaults {
    private enum Key {
        static let userNickName = "userNickName"
    }
    
    func saveUserNickName(_ nickName: String) {
        set(nickName, forKey: Key.userNickName)
    }

    /// 닉네임 불러오기
    var loadUserNickName: String {
        string(forKey: Key.userNickName) ?? ""
    }

    /// 닉네임 삭제
    func removeUserNickName() {
        removeObject(forKey: Key.userNickName)
    }
}
