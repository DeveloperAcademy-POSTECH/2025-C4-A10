//
//  GimiButtonStyle.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/21/25.
//

import SwiftUI

enum GimiButtonType {
    case stroke
    case primary
    case green
}

struct GimiButtonStyle: ButtonStyle {
    let type: GimiButtonType

    func makeBody(configuration: Configuration) -> some View {
        GimiButtonStyleView(
            configuration: configuration,
            type: type
        )
    }

    struct GimiButtonStyleView: View {
        @Environment(\.isEnabled) private var isEnabled
        let configuration: Configuration
        let type: GimiButtonType

        var body: some View {
            configuration.label
                .font(.title2)
                .frame(maxWidth: .infinity)
                .padding()
                .background(backgroundColor)
                .foregroundColor(foregroundColor)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(borderColor, lineWidth: strokeWidth)
                )
                .opacity(configuration.isPressed ? 0.8 : 1)
        }

        // MARK: Color
        
        private var foregroundColor: Color {
            if !isEnabled {
                return .white
            }

            switch type {
            case .stroke:
                return .primaryBase
            case .primary:
                return .white
            case .green:
                return .primaryDarken100
            }
        }

        private var backgroundColor: Color {
            if !isEnabled {
                return .gray100
            }

            switch type {
            case .stroke:
                return .clear
            case .primary:
                return .primaryBase
            case .green:
                return .brandGreen200
            }
        }

        // MARK: Border
        
        private var borderColor: Color {
            switch type {
            case .stroke:
                return .primaryBase
            default:
                return .clear
            }
        }

        private var strokeWidth: CGFloat {
            (type == .stroke && isEnabled) ? 1.5 : 0
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        Button("비활성화") {}
            .buttonStyle(GimiButtonStyle(type: .primary))
            .disabled(true)
        
        Button("스트로크 버튼") {}
            .buttonStyle(GimiButtonStyle(type: .stroke))
        
        Button("프라이머리 버튼") {}
            .buttonStyle(GimiButtonStyle(type: .primary))
        
        Button("그린 버튼") {}
            .buttonStyle(GimiButtonStyle(type: .green))
    }
    .padding()
    .frame(width: 351)
    .background(Color.gray.opacity(0.1)) // 배경색은 시각적 구분용
}
