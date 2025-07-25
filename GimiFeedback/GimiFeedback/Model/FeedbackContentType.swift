//
//  FeedbackContentType.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/9/25.
//

enum FeedbackContentType: Int, Codable, Identifiable, CaseIterable {
    case typeContinue = 0
    case typeStop
    case typeStart
    case other
    
    var title: String {
        switch self {
        case .typeContinue:
            "Continue"
        case .typeStop:
            "Stop"
        case .typeStart:
            "Start"
        case .other:
            "추가로 할말"
        }
    }
    
    var content: String {
        switch self {
        case .typeContinue:
            "계속해서 지속하면 좋을 점을 작성해주세요"
        case .typeStop:
            "멈추면 좋을 부분을 적어주세요."
        case .typeStart:
            "해당 내용들로 어떤걸 시작하면 좋을지 적어주세요"
        case .other:
            "마지막으로 하고 싶은 말을 적어주세요"
        }
    }
    
    var id: Int { rawValue }
}
