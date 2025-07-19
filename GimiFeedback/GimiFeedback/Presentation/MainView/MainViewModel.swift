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
    }
    
    let router: MainNavigationRouter
    
    init(router: MainNavigationRouter) {
        self.router = router
    }
    
    func send(_ action: Action) {
        switch action {
        case .handleDeepLink(let url):
            Task {
                if let channel = await DeepLinkManager.shared.handleFeedbackWriteDeepLink(url: url) {
                    await MainActor.run {
                        router.push(to: .feedbackWrite(channel: channel))
                    }
                }
            }
        }
    }
}
