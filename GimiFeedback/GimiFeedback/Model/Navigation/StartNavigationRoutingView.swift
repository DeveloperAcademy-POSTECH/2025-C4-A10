//
//  NavigationRoutingView.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/15/25.
//

import SwiftUI

struct StartNavigationRoutingView: View {
    
    @State var destination: StartNavigationDestination
    @EnvironmentObject var router: OnboardingNavigationRouter
    
    var body: some View {
        Group {
            switch destination {
            case .inputCode:
                InputCodeView { feedbackChannel in
                    router.push(to: .feedbackWrite(channel: feedbackChannel))
                }
            case .nickNameInput:
                NickNameInputView()
            case .feedbackWrite(let feedbackChannel):
                FeedbackWriteView(feedbackChannel: feedbackChannel) {
                    router.push(to: .feedbackWriteComplete)
                }
            case .feedbackWriteComplete:
                FeedbackWriteCompleteView()
            }
        }
    }
}
