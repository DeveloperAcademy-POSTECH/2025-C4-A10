//
//  FirebaseAuthManager.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/12/25.
//

import FirebaseAuth

final class FirebaseAuthManager {
    
    static let shared = FirebaseAuthManager()
    static var currentUser: Bool {
        return Auth.auth().currentUser != nil
    }
    
    private init() {}
    
    /// 회원가입
    func emailAuthSignUp(email: String, password: String) async throws -> String {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        
        return result.user.email ?? ""
    }

    /// 로그인
    func emailAuthLogin(email: String, password: String) async throws -> String {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        
        return result.user.email ?? ""
    }

    /// 이미 회원가입 된 유저 처리
    func isEmailAlreadyInUseError(_ error: Error) -> Bool {
        if let errCode = AuthErrorCode(rawValue: (error as NSError).code),
           errCode == .emailAlreadyInUse {
            return true
        }
        return false
    }

    func logout() throws {
        try Auth.auth().signOut()
    }
}
