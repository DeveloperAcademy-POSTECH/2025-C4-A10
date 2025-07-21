//
//  Font.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/8/25.
//

import SwiftUI

extension Font {
    private static let fontName = "SUIT-Variable"

    enum SuitWeight {
        case regular
        case medium
        case semibold
        case bold

        var fontWeight: Font.Weight {
            switch self {
            case .regular:
                return .regular
            case .medium:
                return .medium
            case .semibold:
                return .semibold
            case .bold:
                return .bold
            }
        }
    }

    static func suit(_ weight: SuitWeight, size: CGFloat) -> Font {
        return .custom(fontName, size: size).weight(weight.fontWeight)
    }

    static var title1: Font { .suit(.bold, size: 20) }
    static var title2: Font { .suit(.bold, size: 18) }
    static var headline: Font { .suit(.semibold, size: 17) }
    static var body: Font { .suit(.regular, size: 17) }
    static var callout: Font { .suit(.medium, size: 16) }
    static var callout2: Font { .suit(.semibold, size: 15) }
    static var inputCode: Font { .suit(.regular, size: 15) }
    static var footnote: Font { .suit(.semibold, size: 13) }
    static var caption1: Font { .suit(.regular, size: 13) }
}
