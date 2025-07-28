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
    @EnvironmentObject var userViewModel: UserViewModel
    
    var body: some View {
        Group {
            switch destination {
            case .startUserinputNickName:
                InputNickNameView(mode: .startUserInput) { inputNickName in
                    userViewModel.send(.nickNameSave(inputNickName))
                }
            case .inputCode:
                InputCodeView { feedbackChannel in
                    router.push(to: .feedbackWriteInputNickName(channel: feedbackChannel))
                }
            case .feedbackWriteInputNickName(let channel):
                InputNickNameView(mode: .feedbackWriteInput) { inputNickName in
                    router.push(to: .feedbackWrite(
                        channel: channel,
                        inputNickName: inputNickName
                    ))
                }
            case let .feedbackWrite(feedbackChannel, nickName):
                FeedbackWriteView(
                    feedbackChannel: feedbackChannel,
                    inputNickName: nickName
                ) {
                    router.push(to: .feedbackWriteComplete)
                }

            case .feedbackWriteComplete:
                FeedbackWriteCompleteView {
                    router.popToRootView()
                }
            }
        }
    }
}
