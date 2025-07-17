//
//  DeepLinkManager.swift
//  GimiFeedback
//
//  Created by 승찬 on 7/17/25.
//

import Foundation

final class DeepLinkManager {
    static var shared = DeepLinkManager()
    
    private init() { }
    
    /// 외부 URL 딥링크를 처리하여 피드백 작성 화면으로 이동하는 공통 핸들러 함수
    /// url: 외부에서 앱을 연 URL
    /// router: 현재 사용하는 네비게이션 라우터
    /// destination: FeedbackChannel을 기반으로 push할 Destination 생성하는 클로저
    func handleFeedbackWriteDeepLink<T: NavigationDestination>(
        url: URL,
        router: NavigationRouter<T>,
        destination: @escaping (FeedbackChannel) -> T) {
            
            print("딥링크 URL", url)
            
            /// URL의 scheme이 설정한게 맞는지 (Info에서 설정한 값)
            guard url.scheme == "gimifeedback",
                  url.host(percentEncoded: false) == "feedbackWrite",
                  /// 첫번째 "/" 이후 컴포넌트부터 시작
                  let idString = url.pathComponents.dropFirst().first,
                  let uuid = UUID(uuidString: idString) else {
                print("잘못된 URL 형식")
                return
            }
            
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
