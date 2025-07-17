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
            case .login:
                LoginView()
            case .feedbackWriteComplete:
                // TODO: 피드백 완료 이동
                EmptyView()
            case .feedbackWrite(let feedbackChannel):
                // TODO: 피드백 생성 이동
                FeedbackWriteView(feedbackChannel: feedbackChannel)
            }
        }
    }
}
