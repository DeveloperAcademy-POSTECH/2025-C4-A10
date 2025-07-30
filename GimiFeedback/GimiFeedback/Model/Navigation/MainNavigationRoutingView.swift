//
//  MainNavigationRoutingView.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/15/25.
//

import SwiftUI

struct MainNavigationRoutingView: View {
    
    @State var destination: MainNavigationDestination
    @EnvironmentObject var router: MainNavigationRouter
    @EnvironmentObject var userViewModel: UserViewModel
    
    var body: some View {
        Group {
            switch destination {
            case .updateNickName:
                InputNickNameView(
                    inputNickName: userViewModel.saveUserNickName,
                    mode: .updateNickName
                ) { updateNickName in
                    userViewModel.send(.nickNameSave(updateNickName))
                    router.pop()
                }
            case .channelDetail(let channelItem):
                ChannelDetailView(channelItem: channelItem)
            case .channelEdit(let channelItem):
                ChannelEditView(channelItem: channelItem)
            case .feedbackDetail(let feedbackItem):
                FeedbackDetailView(feedbackItem: feedbackItem)
            case .inputCode:
                InputCodeView { feedbackChannel in
                    router.push(to: .feedbackWrite(channel: feedbackChannel))
                }
            case .feedbackWrite(let feedbackChannel):
                FeedbackWriteView(
                    feedbackChannel: feedbackChannel,
                    inputNickName: userViewModel.saveUserNickName
                ) {
                    router.push(to: .feedbackWriteComplete)
                }
            case .feedbackWriteComplete:
                FeedbackWriteCompleteView {
                    router.popToRootView()
                }
            case .feedbackChannelCreate:
                ChannelCreateView()
            case .feedbackChannelCreateComplete(let channelId):
                ChannelCreateCompleteView(channelId: channelId)
            }
        }
    }
}
