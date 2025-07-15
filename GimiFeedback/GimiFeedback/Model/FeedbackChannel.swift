//
//  FeedbackChannel.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/9/25.
//

import Foundation

struct FeedbackChannel: Codable, Identifiable, Hashable {
    let id: UUID
    let userID: UUID
    let channelTitle: String
    var content: String
    
    init(
        id: UUID = UUID(),
        userID: UUID,
        channelTitle: String,
        content: String
    ) {
        self.id = id
        self.userID = userID
        self.channelTitle = channelTitle
        self.content = content
    }
}

extension FeedbackChannel: EntityRepresentable {
    var entityName: CollectionType { .feedbackChannel }
    var documentID: String { id.uuidString }
}
