//
//  Chat.swift
//  GimiFeedback
//
//  Created by 승찬 on 7/28/25.
//

import Foundation

/// 요청용 메시지
struct ChatMessage: Codable {
    let role: String // user, system
    let content: String
}

/// 요청 내용
struct ChatRequest: Codable {
    let model: String // 사용할 모델 이름 (ex: gpt-4o)
    let messages: [ChatMessage] // 대화 내용 (role, content 배열)
    let temperature: Double
    let top_p: Double
}

/// 응답 메시지 (GPT가 생성한 메시지)
struct ChatResponse: Codable {
    let role: String
    let content: String
}

/// 응답의 선택지 중 하나
struct Choice: Codable {
    let message: ChatResponse
}

/// 전체 응답 구조
struct ChatCompletionResponse: Codable {
    let choices: [Choice]
}
