//
//  KakaoShareManager.swift
//  GimiFeedback
//
//  Created by 승찬 on 7/18/25.
//

import Foundation
import KakaoSDKTemplate
import KakaoSDKShare
import UIKit

final class KakaoShareManager {
    static let shared = KakaoShareManager()
    private init() { }
    
    func shareToKakao(channelID: String) {
        let template = createFeedTemplate(channelID: channelID)
        
        if ShareApi.isKakaoTalkSharingAvailable() {
            ShareApi.shared.shareDefault(templatable: template) { result, error in
                if let error = error {
                    print("카카오톡 공유 실패: \(error.localizedDescription)")
                    return
                }
                
                if let url = result?.url {
                    UIApplication.shared.open(url)
                }
            }
        } else {
            if let webUrl = ShareApi.shared.makeDefaultUrl(templatable: template) {
                UIApplication.shared.open(webUrl)
            } else {
                print("공유 URL 생성 실패")
            }
        }
    }
}

extension KakaoShareManager {
    private func createFeedTemplate(channelID: String) -> FeedTemplate {
        
        let content = Content(
            title: "기미 피드백",
            description: "피드백을 남겨주세요",
            link: .init(
                webUrl: URL(string: "https://developers.kakao.com/"),
                mobileWebUrl: URL(string: "https://developers.kakao.com/"))
        )
        
        let buttons = [
            Button(
                title: "카카오 사이트 열기",
                link: .init(
                    webUrl: URL(string: "https://developers.kakao.com/"),
                    mobileWebUrl: URL(string: "https://developers.kakao.com/"))
            ),
            
            Button(
                title: "앱에서 피드백 남기기",
                link: .init(
                    webUrl: URL(string: "https://developers.kakao.com/"),
                    mobileWebUrl: URL(string: "https://developers.kakao.com/"),
                    iosExecutionParams: ["feedbackWrite": channelID])),
        ]
        
        return FeedTemplate(content: content, buttons: buttons)
    }
}
