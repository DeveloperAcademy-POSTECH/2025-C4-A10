//
//  FeedbackContent.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/9/25.
//

struct FeedbackContent {
    let content: String
    let spicy: Int // 매운 맛 단계
    var visiable: Bool
    let type: FeedbackContentType
    
    init(
        content: String,
        spicy: Int,
        visiable: Bool = false,
        type: FeedbackContentType
    ) {
        self.content = content
        self.spicy = spicy
        self.visiable = visiable
        self.type = type
    }
}
