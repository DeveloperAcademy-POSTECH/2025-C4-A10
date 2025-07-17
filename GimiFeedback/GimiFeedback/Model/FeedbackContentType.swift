//
//  FeedbackContentType.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/9/25.
//

enum FeedbackContentType: Int, Codable, Identifiable, CaseIterable {
    case keep = 0
    case problem
    case `try`
    case other
    
    var title: String {
        switch self {
        case .keep:
            "Keep"
        case .problem:
            "Prolem"
        case .try:
            "Try"
        case .other:
            "추가로 할말"
        }
    }
    
    var content: String {
        switch self {
        case .keep:
            "계속해서 지속하면 좋을 점을 작성해주세요"
        case .problem:
            "아직 개선해야 될 문제인 점을 적어주세요"
        case .try:
            "해당 내용들로 어떤 행동을 해야할지 적어주세요"
        case .other:
            "마지막으로 하고 싶은 말을 적어주세요"
        }
    }
    
    var id: Int { rawValue }
}
