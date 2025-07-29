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
    
    static var userNickName: String {
        return Auth.auth().currentUser?.displayName ?? ""
    }
    
    static var currentUserID: String {
        return Auth.auth().currentUser?.uid ?? ""
    }

    private var authStateDidChangeHandle: AuthStateDidChangeListenerHandle?

    private init() {
        authStateDidChangeHandle = Auth.auth().addStateDidChangeListener { _, user in
            print("Firebase auth state changed. user: \(user?.uid ?? "nil")")
            NotificationCenter.default.post(name: .firebaseAuthStateChanged, object: nil)
        }
    }
    
    func emailSignUpOrLogin(email: String, password: String) async throws {
        do {
            try await Auth.auth().createUser(withEmail: email, password: password)
            print("파이어베이스 회원가입 성공: \(email)")
        } catch {
            if isEmailAlreadyInUseError(error) {
                try await Auth.auth().signIn(withEmail: email, password: password)
                print("파이어베이스 로그인 성공: \(email)")
            } else {
                throw error
            }
        }
    }

    // 로그아웃
    func logout() throws {
        try Auth.auth().signOut()
    }
    
    func saveUserNickName(nickName: String) async throws {
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = nickName
        try await changeRequest?.commitChanges()
        NotificationCenter.default.post(name: .firebaseAuthStateChanged, object: nil)
    }
    
    func deleteUser(email: String, password: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw NSError(domain: "Firebase", code: 0, userInfo: [NSLocalizedDescriptionKey: "로그인된 사용자 없음"])
        }

        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        try await user.reauthenticate(with: credential)
        try await user.delete()
    }
}

// MARK: - Private Helpers

extension FirebaseAuthManager {
    /// 이미 회원가입 된 유저 처리
    private func isEmailAlreadyInUseError(_ error: Error) -> Bool {
        if let errCode = AuthErrorCode(rawValue: (error as NSError).code),
           errCode == .emailAlreadyInUse {
            return true
        }
        return false
    }
}

extension Notification.Name {
    static let firebaseAuthStateChanged = Notification.Name("firebaseAuthStateChanged")
}
