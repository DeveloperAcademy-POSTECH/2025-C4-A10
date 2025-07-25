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
            case .profile:
                ProfileView()
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
                FeedbackWriteCompleteView()
            case .feedbackChannelCreate:
                ChannelCreateView()
            case .feedbackChannelCreateComplete(let channelID):
                ChannelCreateCompleteView(channelID: channelID)
            }
        }
    }
}
