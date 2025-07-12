//
//  NavigationHomeDestination.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/12/25.
//

enum NavigationHomeDestination: Hashable {
    case feedbackList
    case channelEdit
    case feedbackDetail
    case inputCode
    case feedbackWrite(code: String)
    case feedbackWriteComplete
    case feedbackChannelCreate
    case feedbackChannelCreateComplete
}
