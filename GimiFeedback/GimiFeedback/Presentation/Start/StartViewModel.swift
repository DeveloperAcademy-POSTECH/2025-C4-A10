//
//  StartViewModel.swift
//  GimiFeedback
//
//  Created by 승찬 on 7/18/25.
//

import Foundation

final class StartViewModel: ViewModelable {
    enum Action {
        case handleDeepLink(URL)
    }
    
    let router: OnboardingNavigationRouter
    
    init(router: OnboardingNavigationRouter) {
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
