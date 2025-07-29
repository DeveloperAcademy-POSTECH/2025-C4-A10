//
//  NavigationDestination.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/9/25.
//

protocol NavigationDestination: Hashable {}

// MARK: Onboarding
enum StartNavigationDestination: NavigationDestination {
    case startUserinputNickName
    case inputCode
    case feedbackWriteInputNickName(channel: FeedbackChannel)
    case feedbackWrite(channel: FeedbackChannel, inputNickName: String)
    case feedbackWriteComplete
}

// MARK: Main
enum MainNavigationDestination: NavigationDestination {
    case updateNickName
    case channelDetail(channelItem: FeedbackChannel)
    case channelEdit(channelItem: FeedbackChannel)
    case feedbackDetail(feedback: Feedback)
    case inputCode
    case feedbackWrite(channel: FeedbackChannel)
    case feedbackWriteComplete
    case feedbackChannelCreate
    case feedbackChannelCreateComplete(channelID: String)
}
