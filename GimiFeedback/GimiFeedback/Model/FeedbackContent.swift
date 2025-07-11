//
//  FeedbackContent.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/9/25.
//

import Foundation

struct FeedbackContent: Codable, Identifiable {
    let id: UUID
    let content: String
    let spicy: Int // 매운 맛 단계
    var visiable: Bool
    let type: FeedbackContentType
    
    init(
        id: UUID = UUID(),
        content: String,
        spicy: Int,
        visiable: Bool = false,
        type: FeedbackContentType
    ) {
        self.id = id
        self.content = content
        self.spicy = spicy
        self.visiable = visiable
        self.type = type
    }
}

extension FeedbackContent: EntityRepresentable {
    var entityName: CollectionType { .feedbackContent }
    var documentID: String { id.uuidString }
}
