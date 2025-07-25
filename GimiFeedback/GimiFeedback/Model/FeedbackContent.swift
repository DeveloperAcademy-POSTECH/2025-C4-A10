//
//  FeedbackContent.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/9/25.
//

import Foundation
import SwiftUI

struct FeedbackContent: Codable, Identifiable, Hashable {
    let id: UUID
    let content: String
    let spicy: Int // 매운 맛 단계
    var visiable: Bool
    let type: FeedbackContentType
    
    var spicyLabel: String {
        switch spicy {
        case 0:
            return "착한맛"
        case 1:
            return "보통맛"
        case 2:
            return "매운맛"
        case 3:
            return "불닭맛"
        default:
            return "알 수 없음"
        }
    }

    var spicyColor: Color {
        switch spicy {
        case 0:
            return .brandGreen300
        case 1:
            return .brandYellow300
        case 2:
            return .brandRed300
        case 3:
            return .deepRed300
        default:
            return .gray
        }
    }
    
    var spicyImage: String {
        switch spicy {
        case 0:
            return "Mild"
        case 1:
            return "Normal"
        case 2:
            return "Spicy"
        case 3:
            return "Hell"
        default:
            return ""
        }
    }

    var backgroundColor: Color {
        switch spicy {
        case 0:
            return .brandGreen100
        case 1:
            return .brandYellow100
        case 2:
            return .brandRed100
        case 3:
            return .deepRed100
        default:
            return .gray
        }
    }
    
    var fillColor: Color {
        switch spicy {
        case 0:
            return .brandGreen200
        case 1:
            return .brandYellow200
        case 2:
            return .brandRed200
        case 3:
            return .deepRed200
        default:
            return .gray
        }
    }
    
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
