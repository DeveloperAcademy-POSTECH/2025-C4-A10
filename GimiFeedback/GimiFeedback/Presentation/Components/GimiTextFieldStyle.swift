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

struct GimiTextFieldStyle: TextFieldStyle {
    let style: GimiTextFieldStyleType

    func _body(configuration: TextField<Self._Label>) -> some View {
        switch style {
        case .base:
            configuration
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
            configuration
                .padding()
                .background(.gray50)
                .cornerRadius(12)
                .font(.body)
                .foregroundColor(.black)
        }
    }
}

extension TextFieldStyle where Self == GimiTextFieldStyle {
    static var gimiBase: GimiTextFieldStyle {
        GimiTextFieldStyle(style: .base)
    }

    static var gimiTitle: GimiTextFieldStyle {
        GimiTextFieldStyle(style: .title)
    }
}

/// 텍스트 필드 글자수 제한
struct TextFieldLimitModifier: ViewModifier {
    @Binding var text: String
    let maximumText: Int
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .trailing) {
                Text("(\(text.count) / \(maximumText))")
                    .font(.caption1)
                    .foregroundColor(.gray700)
                    .padding()
            }
            .onChange(of: text) { _, newValue in
                if newValue.count > maximumText {
                    text = String(newValue.prefix(maximumText))
                }
            }
    }
}

extension View {
    func textFieldLimit(text: Binding<String>, maximumText: Int) -> some View {
        self.modifier(TextFieldLimitModifier(text: text, maximumText: maximumText))
    }
}

#Preview {
    struct PreviewContainer: View {
        @State private var texts = ["", "test"]
        private let placeHolder = "PlaceHolder"
        @State private var test = "12412421421421"
        
        var body: some View {
            VStack(spacing: 16) {
                ForEach($texts.indices, id: \.self) { index in
                    TextField("test용 입니다.", text: $texts[index])
                        .textFieldStyle(.gimiBase)
                }
                TextField("제목 입력", text: $test)
                    .textFieldStyle(.gimiTitle)
                    .textFieldLimit(text: $test, maximumText: 15)
            }
            .padding()
            .background(.white)
        }
    }
    
    return PreviewContainer()
}
