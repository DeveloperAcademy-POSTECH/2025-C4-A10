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
    
    var contentCount: String {
        var itemList: [String] = []
        
        let typeContinue = content.filter { $0.type == .typeContinue }.count
        let typeStop = content.filter { $0.type == .typeStop }.count
        
        if typeContinue > .zero {
            itemList.append("Continue \(typeContinue)")
        }
        
        if typeStop > .zero {
            itemList.append("Stop \(typeStop)")
        }
        
        return itemList.joined(separator: ", ")
    }
    
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
