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
    
    var id: Int { rawValue }
}
