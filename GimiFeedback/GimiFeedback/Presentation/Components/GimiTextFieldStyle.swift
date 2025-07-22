//
//  GimiTextFieldStyle.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/22/25.
//

import SwiftUI

enum GimiTextFieldStyleType {
    case base
    case title
}

struct GimiTextFieldStyle: ViewModifier {
    let style: GimiTextFieldStyleType

    func body(content: Content) -> some View {
        switch style {
        case .base:
            content
                .padding(.vertical, 8)
                .padding(.horizontal, 4)
                .font(.inputCode)
                .overlay(
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(.primaryBase),
                    alignment: .bottom
                )
                .tint(.primaryLighten200)

        case .title:
            content
                .padding()
                .background(.gray50)
                .cornerRadius(12)
                .font(.body)
                .foregroundColor(.black)
        }
    }
}

extension View {
    func textFieldStyle(_ style: GimiTextFieldStyleType) -> some View {
        self.modifier(GimiTextFieldStyle(style: style))
    }
}

#Preview {
    struct PreviewContainer: View {
        @State private var texts = ["", "test"]
        private let placeHolder = "PlaceHolder"
        
        var body: some View {
            VStack(spacing: 16) {
                ForEach($texts.indices, id: \.self) { index in
                    TextField("test용 입니다.", text: $texts[index])
                        .textFieldStyle(.base)
                }
                TextField("제목 입력", text: .constant(""))
                    .textFieldStyle(.title)
            }
            .padding()
            .background(.gray400)
        }
    }
    
    return PreviewContainer()
}
