//
//  NavigationDestination.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/9/25.
//

protocol NavigationDestination: Hashable {}

// MARK: Onboarding
enum OnboardingNavigationDestination: NavigationDestination {
    case login
    case inputCode
    case feedbackWrite(code: String)
    case feedbackWriteComplete
}

// MARK: Main
enum MainNavigationDestination: NavigationDestination {
    case feedbackList
    case channelEdit
    case feedbackDetail
    case inputCode
    case feedbackWrite(code: String)
    case feedbackWriteComplete
    case feedbackChannelCreate
    case feedbackChannelCreateComplete
}
