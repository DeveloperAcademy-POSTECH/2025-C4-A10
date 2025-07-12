//
//  NavigationOnboardingDestination.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/9/25.
//

enum NavigationOnboardingDestination: Hashable {
    case login
    case inputCode
    case feedbackWrite(code: String)
    case feedbackWriteComplete
}
