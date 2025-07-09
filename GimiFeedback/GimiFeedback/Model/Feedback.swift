//
//  Feedback.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/8/25.
//

import Foundation

struct Feedback {
    let id: UUID
    let read: UUID  // 받는 사람
    let write: String   // 작성한 사람 닉네임
    let content: [FeedbackContent]
    let date: Date
    let title: String   // Category의 title
    var visiable: Bool
}
