//
//  LoginViewModel.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/12/25.
//

@MainActor
final class LoginViewModel: ViewModelable {
    enum Action {
        case kakaoLogin
        case kakaoLogout
    }
    
    func send(_ action: Action) {
        switch action {
        case .kakaoLogin:
            kakaoLogin()
        case .kakaoLogout:
            kakaoLogout()
        }
    }
    
    private func kakaoLogin() {
        Task {
            do {
                let (email, password) = try await KakaoAuthManager.shared.kakaoAuthSignIn()
                print("로그인 성공: \(email), 비밀번호: \(password)")
            } catch {
                print("로그인 실패: \(error.localizedDescription)")
            }
        }
    }
    
    private func kakaoLogout() {
        Task {
            do {
                try await KakaoAuthManager.shared.logout()
                print("로그아웃 성공")
            } catch {
                print("로그아웃 실패: \(error.localizedDescription)")
            }
        }
    }
}
