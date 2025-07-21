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
                do {
                    if let channelId = DeepLinkManager.shared.handleFeedbackWriteDeepLink(
                        url: url
                    ) {
                        let getChannel: FeedbackChannel? = try await FirestoreManager.shared.get(
                            channelId.uuidString,
                            collectionType: .feedbackChannel
                        )
                        channel = getChannel
                    }
                } catch {
                    print("Get 에러: \(error.localizedDescription)")
                }
            }
        case .resetChannel:
            channel = nil
        }
    }
}
