//
//  FeedbackCategory.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/9/25.
//

import Foundation

struct FeedbackCategory {
    let id: UUID
    let userID: UUID
    var feedback: [Feedback]
    let title: String
    let content: String
}
