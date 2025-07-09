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
    var content: String
    
    init(
        id: UUID = UUID(),
        userID: UUID,
        feedback: [Feedback] = [],
        title: String,
        content: String
    ) {
        self.id = id
        self.userID = userID
        self.feedback = feedback
        self.title = title
        self.content = content
    }
}
