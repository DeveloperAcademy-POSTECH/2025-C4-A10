//
//  DeepLinkManager.swift
//  GimiFeedback
//
//  Created by 승찬 on 7/17/25.
//

import Foundation

final class DeepLinkManager {
    static let shared = DeepLinkManager()
    private init() { }
    
    /// 외부에서 전달된 딥링크 URL로부터 FeedbackChannel을 비동기적으로 가져오는 메서드
     ///
     /// - Parameter url: 외부에서 전달된 딥링크 URL (카카오톡 공유, 알림 등)
     /// - Returns: 유효한 FeedbackChannel 객체 또는 nil
    func handleFeedbackWriteDeepLink(url: URL) async -> FeedbackChannel? {
        guard let uuid = extractUUID(url: url) else {
            print("유효하지 않은 딥링크 URL: \(url)")
            return nil
        }
        
        do {
            let channelItem: FeedbackChannel? = try await FirestoreManager.shared.get(
                uuid.uuidString,
                collectionType: .feedbackChannel
            )
            return channelItem
            
        } catch {
            print("Firestore 조회 실패:", error.localizedDescription)
            return nil
        }
    }
}

extension DeepLinkManager {
    
    /// 딥링크 URL에서 피드백 채널 UUID를 추출
    /// 유효한 UUID가 있으면 반환, 없으면 nil
    private func extractUUID(url: URL) -> UUID? {
        // 1. 쿼리 파라미터 방식: kakaoScheme://...?feedbackWrite=<UUID>
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let id = components.queryItems?.first(where: { $0.name == "feedbackWrite" })?.value,
           let uuid = UUID(uuidString: id) {
            return uuid
        }
        
        // 2. URL 스킴 방식: gimifeedback://feedbackWrite/<UUID>
        if url.scheme == "gimifeedback",
           url.host?.lowercased() == "feedbackwrite",
           let id = url.pathComponents.dropFirst().first,
           let uuid = UUID(uuidString: id) {
            return uuid
        }
        
        return nil
    }
}
