//
//  Feedback.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/8/25.
//

import Foundation

struct Feedback {
    let id: UUID
    let readPerson: UUID  // 받는 사람
    let writePerson: String   // 작성한 사람 닉네임
    var content: [FeedbackContent]
    let date: Date
    let title: String   // Category의 title
    var visiable: Bool
    
    init(
        id: UUID = UUID(),
        read: UUID,
        write: String,
        content: [FeedbackContent],
        date: Date = Date(),
        title: String,
        visiable: Bool = false
    ) {
        self.id = id
        self.readPerson = read
        self.writePerson = write
        self.content = content
        self.date = date
        self.title = title
        self.visiable = visiable
    }
}
