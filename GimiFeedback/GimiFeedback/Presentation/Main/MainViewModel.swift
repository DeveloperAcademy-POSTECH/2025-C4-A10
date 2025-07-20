//
//  MainViewModel.swift
//  GimiFeedback
//
//  Created by 승찬 on 7/18/25.
//

import Foundation

final class MainViewModel: ViewModelable {
    enum Action {
        case handleDeepLink(URL)
        case resetChannel
    }
    
    @Published private(set) var channel: FeedbackChannel?
    
    func send(_ action: Action) {
        switch action {
        case .handleDeepLink(let url):
            Task {
                if let getChannel = await DeepLinkManager.shared.handleFeedbackWriteDeepLink(
                    url: url
                ) {
                    channel = getChannel
                }
            }
        case .resetChannel:
            channel = nil
        }
    }
}
