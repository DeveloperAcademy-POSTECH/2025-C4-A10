//
//  CollectionType.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/9/25.
//

/// Firebase에 데이터를 저장하기 위한 key 값
/// 해당 부분으로 데이터 식별
/// User -> User 부분으로 가서 데이터를 검색
enum CollectionType: String {
    case feedbackChannel = "FeedbackChannel"
    case feedback = "Feedback"
    case feedbackContent = "FeedbackContent"
    case feedbackContentType = "FeedbackContentType"
    case token = "Token"
}
