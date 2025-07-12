//
//  KakaoAuth.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/12/25.
//

import KakaoSDKAuth
import KakaoSDKUser
import Foundation

final class KakaoAuthManager {

    static let shared = KakaoAuthManager()
    
    private init() {}

    /// 카카오 로그인  함수
    /// 토큰 유효시 -> 사용자 정보 반환
    /// 유효 X -> 카카오톡 로그인 시도 후 사용자 정보 반환
    func kakaoAuthSignIn() async throws -> (email: String, password: String) {
        if AuthApi.hasToken() {
            do {
                _ = try await getAccessTokenInfo()
                return try await fetchUserInfo()
            } catch {
                return try await loginThroughKakao()
            }
        } else {
            return try await loginThroughKakao()
        }
    }
    
    /// 카카오 로그아웃 함수
    /// 토큰 만료 시키고 삭제
    func logout() async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            UserApi.shared.logout { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
}

// MARK: - Private Helpers

extension KakaoAuthManager {
    
    /// 사용자 정보 불러오기 (email, user ID 기반 password 반환)
    private func fetchUserInfo() async throws -> (email: String, password: String) {
        try await withCheckedThrowingContinuation { continuation in
            UserApi.shared.me { user, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let email = user?.kakaoAccount?.email,
                      let password = user?.id else {
                    continuation.resume(
                        throwing: NSError(
                            domain: "KakaoAuthError",
                            code: 0,
                            userInfo: [NSLocalizedDescriptionKey: "사용자 정보 없음"]
                        )
                    )
                    return
                }

                continuation.resume(returning: (email, "\(password)"))
            }
        }
    }

    /// 액세스 토큰이 유효한지 확인
    private func getAccessTokenInfo() async throws -> AccessTokenInfo {
        try await withCheckedThrowingContinuation { continuation in
            UserApi.shared.accessTokenInfo { info, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let info = info {
                    continuation.resume(returning: info)
                } else {
                    continuation.resume(
                        throwing: NSError(
                            domain: "KakaoAuthError",
                            code: 1,
                            userInfo: [NSLocalizedDescriptionKey: "토큰 정보 없음"]
                        )
                    )
                }
            }
        }
    }

    /// 카카오톡 앱 또는 계정 로그인 시도 후 사용자 정보 반환
    private func loginThroughKakao() async throws -> (email: String, password: String) {
        if UserApi.isKakaoTalkLoginAvailable() {
            _ = try await loginWithKakaoTalk()
        } else {
            _ = try await loginWithKakaoAccount()
        }
        return try await fetchUserInfo()
    }

    /// 카카오톡 앱 로그인
    private func loginWithKakaoTalk() async throws -> OAuthToken {
        try await withCheckedThrowingContinuation { continuation in
            UserApi.shared.loginWithKakaoTalk { token, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let token = token {
                    continuation.resume(returning: token)
                }
            }
        }
    }

    /// 카카오 계정(웹) 로그인
    private func loginWithKakaoAccount() async throws -> OAuthToken {
        try await withCheckedThrowingContinuation { continuation in
            UserApi.shared.loginWithKakaoAccount { token, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let token = token {
                    continuation.resume(returning: token)
                }
            }
        }
    }
}
