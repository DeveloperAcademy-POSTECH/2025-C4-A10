//
//  UserViewModel.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/12/25.
//

import Combine
import Foundation

final class UserViewModel: ViewModelable {
    enum Action {
        case kakaoLogin
        case kakaoLogout
        case nickNameSave(String)
    }
    
    @Published private(set) var isLoggedIn: Bool = FirebaseAuthManager.currentUser
    @Published private(set) var saveUserNickName: String = FirebaseAuthManager.userNickName
    @Published private(set) var userId: String = FirebaseAuthManager.currentUserID
    
    private var cancellable: AnyCancellable?
    
    init() {
        observeFirebaseAuthState()
    }

    private func observeFirebaseAuthState() {
        cancellable = NotificationCenter.default
            .publisher(for: .firebaseAuthStateChanged)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                self.isLoggedIn = FirebaseAuthManager.currentUser
                self.saveUserNickName = FirebaseAuthManager.userNickName
                self.userId = FirebaseAuthManager.currentUserID
            }
    }
    
    func send(_ action: Action) {
        switch action {
        case .kakaoLogin:
            Task {
                if let result = await kakaoLogin() {
                    await firebaseAuthSignUpOrLogin(
                        email: result.email,
                        password: result.password
                    )
                }
            }
        case .kakaoLogout:
            Task {
                await kakaoLogout()
                if let logoutUserID = firebaseAuthLogout() {
                    await deleteUser(userID: logoutUserID)
                }
            }
        case .nickNameSave(let inputNickName):
            Task {
                await saveUser(nickName: inputNickName)
                await nickNameChange(nickName: inputNickName)
            }
        }
    }
}

// MARK: - Private Helpers

extension UserViewModel {
    
    // MARK: 로그인
    
    /// 카카오 로그인
    private func kakaoLogin() async -> (email: String, password: String)? {
        do {
            let result = try await KakaoAuthManager.shared.signIn()
            print("카카오 로그인 성공: \(result.email)")
            
            return result
        } catch {
            print("카카오 로그인 실패: \(error.localizedDescription)")
            
            return nil
        }
    }
    
    /// 파이어베이스 회원가입 또는 로그인
    private func firebaseAuthSignUpOrLogin(email: String, password: String) async {
        do {
            try await FirebaseAuthManager.shared.emailSignUpOrLogin(
                email: email,
                password: password
            )
        } catch {
            print("회원가입, 로그인 실패: \(error.localizedDescription)")
        }
    }
    
    // MARK: 로그아웃
    
    /// 카카오 로그아웃 로직
    private func kakaoLogout() async {
        do {
            try await KakaoAuthManager.shared.logout()
            print("카카오 로그아웃 성공")
        } catch {
            print("카카오 로그아웃 실패: \(error.localizedDescription)")
        }
    }
    
    /// 파이어베이스 로그아웃 로직
    private func firebaseAuthLogout() -> String? {
        do {
            let userId = userId
            try FirebaseAuthManager.shared.logout()
            print("파이어베이스 로그아웃 성공")
            
            return userId
        } catch {
            print("파이어베이스 로그아웃 실패: \(error.localizedDescription)")
            
            return nil
        }
    }
    
    // MARK: 토큰 관련 함수
    
    /// 유저 저장 (로그인시)
    private func saveUser(nickName: String) async {
        do {
            let tokenString = try await FCMManager.shared.getTokenString()
            let userID = FirebaseAuthManager.currentUserID
            let user = User(
                userID: userID,
                nickName: nickName,
                fcmToken: tokenString,
                badgeCount: 0
            )
            
            _ = try await FirestoreManager.shared.create(user)
        } catch {
            print("Token 저장 실패")
        }
    }
    
    /// 유저 저장 삭제 (로그아웃시)
    private func deleteUser(userID: String) async {
        do {
            if let user: User = try await FirestoreManager.shared.get(
                userID,
                collectionType: .user
            ) {
                try await FirestoreManager.shared.delete(user)
                print("FCM Token 삭제 성공")
            }
        } catch {
            print("FCM Token 삭제 실패")
        }
    }
    
    private func nickNameChange(nickName: String) async {
        do {
            try await FirebaseAuthManager.shared.saveUserNickName(nickName: nickName)
        } catch {
            print("NickName 변경 실패", error.localizedDescription)
        }
    }
}
