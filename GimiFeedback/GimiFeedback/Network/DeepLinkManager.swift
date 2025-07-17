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
    
    /// 딥링크 URL을 처리하여 FeedbackChannel을 조회한 뒤, 특정 Destination으로 이동
    ///
    /// - Parameters:
    ///   - url: 외부에서 전달된 딥링크 URL
    ///   - router: 현재 NavigationRouter 객체
    ///   - destination: 조회된 FeedbackChannel을 이용해 destination을 구성하는 클로저
    func handleFeedbackWriteDeepLink<T: NavigationDestination>(
        url: URL,
        router: NavigationRouter<T>,
        destination: @escaping (FeedbackChannel) -> T) {
            print("딥링크 URL", url)
            
            guard let uuid = extractUUID(url: url) else { return }
            fetchChannelAndNavigate(uuid: uuid, router: router, destination: destination)
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
    
    /// Firestore에서 채널 정보를 불러온 뒤, 해당 destination으로 네비게이션 push
    private func fetchChannelAndNavigate<T: NavigationDestination>(
        uuid: UUID,
        router: NavigationRouter<T>,
        destination: @escaping (FeedbackChannel) -> T) {
            Task {
                do {
                    let channelItem: FeedbackChannel? = try await FirestoreManager.shared.get(
                        uuid.uuidString,
                        collectionType: .feedbackChannel
                    )
                    
                    guard let channelItem else {
                        print("채널을 찾을 수 없다")
                        return
                    }
                    
                    await MainActor.run {
                        router.push(to: destination(channelItem))
                    }
                } catch {
                    print("Firestore 불러오기 실패", error.localizedDescription)
                }
            }
        }
}
