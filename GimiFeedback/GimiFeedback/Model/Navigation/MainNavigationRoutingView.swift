//
//  MainNavigationRoutingView.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/15/25.
//

import SwiftUI

struct MainNavigationRoutingView: View {
    
    @State var destination: MainNavigationDestination
    
    var body: some View {
        Group {
            switch destination {
            case .channelDetail(let channelItem):
                ChannelDetailView(channelItem: channelItem)
            case .channelEdit:
                ChannelEditView()
            case .feedbackDetail:
                FeedbackDetailView()
            case .inputCode:
                InputCodeView()
            case .feedbackWrite:
                FeedbackWriteView()
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
