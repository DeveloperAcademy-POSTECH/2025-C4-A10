//
//  UserViewModel.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/12/25.
//

import Foundation

final class UserViewModel: ViewModelable {
    enum Action {
        case kakaoLogin
        case kakaoLogout
    }
    
    @Published private(set) var isLoggedIn: Bool = FirebaseAuthManager.currentUser
    var userID: String {
        FirebaseAuthManager.currentUserID ?? ""
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
                    isLoggedIn = FirebaseAuthManager.currentUser
                }
            }
        case .kakaoLogout:
            kakaoLogout()
            firebaseAuthLogout()
            isLoggedIn = FirebaseAuthManager.currentUser
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
    private func kakaoLogout() {
        Task {
            do {
                try await KakaoAuthManager.shared.logout()
                print("카카오 로그아웃 성공")
            } catch {
                print("카카오 로그아웃 실패: \(error.localizedDescription)")
            }
        }
    }
    
    /// 파이어베이스 로그아웃 로직
    private func firebaseAuthLogout() {
        do {
            try FirebaseAuthManager.shared.logout()
            print("파이어베이스 로그아웃 성공")
        } catch {
            print("파이어베이스 로그아웃 실패: \(error.localizedDescription)")
        }
    }
}
