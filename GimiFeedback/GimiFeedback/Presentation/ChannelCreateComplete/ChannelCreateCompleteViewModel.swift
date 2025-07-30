//
//  ChannelCreateCompleteViewModel.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/14/25.
//

import Foundation

final class ChannelCreateCompleteViewModel: ViewModelable {
    enum Action {
        case shareToKakao(String)
    }
    
    let channelId: String
    @Published var showToast: Bool
    
    init(channelId: String, showToast: Bool = false) {
        self.channelId = channelId
        self.showToast = showToast
    }
    
    func send(_ action: Action) {
        switch action {
        case .shareToKakao(let channelID):
            KakaoShareManager.shared.shareToKakao(channelID: channelID)
        }
    }
}
