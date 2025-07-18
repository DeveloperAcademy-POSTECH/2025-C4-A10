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
    
    var body: some View {
        Group {
            switch destination {
            case .channelDetail(let channelItem):
                ChannelDetailView(channelItem: channelItem)
            case .channelEdit:
                ChannelEditView()
            case .feedbackDetail(let feedbackItem):
                FeedbackDetailView(feedbackItem: feedbackItem)
            case .inputCode:
                InputCodeView { feedbackChannel in
                    router.push(to: .feedbackWrite(channel: feedbackChannel))
                }
            case .feedbackWrite(let feedbackChannel):
                FeedbackWriteView(feedbackChannel: feedbackChannel)
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
