//
//  LoginViewModel.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/12/25.
//

final class LoginViewModel: ViewModelable {
    enum Action {
        case kakaoLogin
        case kakaoLogout
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
            kakaoLogout()
        }
    }
}

// MARK: - Private 로직 함수

extension LoginViewModel {
    /// 카카오 로그인
    private func kakaoLogin() async -> (email: String, password: String)? {
        do {
            let result = try await KakaoAuthManager.shared.kakaoAuthSignIn()
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
            let result = try await FirebaseAuthManager.shared.emailAuthSignUp(
                email: email,
                password: password
            )
            
            print("파이어베이스 회원가입 성공: \(result)")
        } catch {
            if FirebaseAuthManager.shared.isEmailAlreadyInUseError(error) {
                await firebaseAuthLogin(email: email, password: password)
            } else {
                print("회원가입 실패: \(error.localizedDescription)")
            }
        }
    }

    /// 파이어베이스 로그인 로직
    private func firebaseAuthLogin(email: String, password: String) async {
        do {
            let result = try await FirebaseAuthManager.shared.emailAuthLogin(
                email: email,
                password: password
            )
            print("파이어베이스 로그인 성공: \(result)")
        } catch {
            print("로그인 실패: \(error.localizedDescription)")
        }
    }
    
    /// 카카오 로그아웃 로직
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
