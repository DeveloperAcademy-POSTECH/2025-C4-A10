//
//  Spicy+Extension.swift
//  GimiFeedback
//
//  Created by 승찬 on 7/26/25.
//

import SwiftUI

extension FeedbackContent {
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
}
