//
//  Font.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/8/25.
//

import SwiftUI

extension Font {
    enum SuitWeight {
        case regular
        case medium
        case semibold
        case bold

        var fontName: String {
            switch self {
            case .regular:
                return "SUITVariable-Regular"
            case .medium:
                return "SUITVariable-Medium"
            case .semibold:
                return "SUITVariable-SemiBold"
            case .bold:
                return "SUITVariable-Bold"
            }
        }
    }

    static func suit(_ weight: SuitWeight, size: CGFloat) -> Font {
        return .custom(weight.fontName, size: size)
    }

    static var title1: Font { .suit(.bold, size: 20) }
    static var title2: Font { .suit(.bold, size: 18) }
    static var title3: Font { .suit(.bold, size: 16) }
    static var headline: Font { .suit(.semibold, size: 17) }
    static var body: Font { .suit(.regular, size: 17) }
    static var callout: Font { .suit(.medium, size: 16) }
    static var callout2: Font { .suit(.semibold, size: 15) }
    static var inputCode: Font { .suit(.regular, size: 15) }
    static var footnote: Font { .suit(.semibold, size: 13) }
    static var caption1: Font { .suit(.regular, size: 13) }
    static var caption2: Font { .suit(.semibold, size: 12) }
    static var caption3: Font { .suit(.medium, size: 12) }
}
