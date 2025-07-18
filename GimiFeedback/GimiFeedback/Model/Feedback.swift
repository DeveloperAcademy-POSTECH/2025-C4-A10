//
//  Feedback.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/8/25.
//

import Foundation

struct Feedback: Codable, Identifiable, Hashable {
    let id: UUID
    let feedbackChannelID: UUID
    let readPerson: String  // 받는 사람
    let writePerson: String   // 작성한 사람 닉네임
    var content: [FeedbackContent]
    let date: Date
    var visiable: Bool
    
    init(
        id: UUID = UUID(),
        feedbackChannelID: UUID,
        readPerson: String,
        writePerson: String,
        content: [FeedbackContent],
        date: Date = Date(),
        visiable: Bool = false
    ) {
        self.id = id
        self.feedbackChannelID = feedbackChannelID
        self.readPerson = readPerson
        self.writePerson = writePerson
        self.content = content
        self.date = date
        self.visiable = visiable
    }
}

extension Feedback: EntityRepresentable {
    var entityName: CollectionType { .feedback }
    var documentID: String { id.uuidString }
}
