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
    
    @Published var showToast: Bool = false
    
    func send(_ action: Action) {
        switch action {
        case .shareToKakao(let channelID):
            KakaoShareManager.shared.shareToKakao(channelID: channelID)
        }
    }
}
