//
//  GimiTextEditorStyle.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/21/25.
//

import SwiftUI

enum GimiTextEditorType {
    case small
    case medium
    case large
}

struct GimiTextEditor: View {
    @Binding var text: String
    let type: GimiTextEditorType
    let placeholder: String
    let isDisabled: Bool

    @FocusState private var isFocused: Bool

    var body: some View {
        TextEditor(text: $text)
            .overlay(alignment: .topLeading) {
                Text(placeholder)
                    .foregroundStyle(text.isEmpty ? .gray : .clear)
                    .font(.callout)
                    .padding(.leading, 6)
            }
            .focused($isFocused)
            .disabled(isDisabled)
            .frame(maxWidth: .infinity)
            .padding(10)
            .background(backgroundColor)
            .scrollContentBackground(.hidden)
            .cornerRadius(12)
            .font(.body)
            .foregroundColor(textColor)
            .frame(height: editorHeight)
    }

    private var backgroundColor: Color {
        isDisabled ? .gray400 : .gray50
    }

    private var textColor: Color {
        isDisabled ? .white : .gray900
    }

    private var editorHeight: CGFloat {
        switch type {
        case .small:
            return 50
        case .medium:
            return 102
        case .large:
            return 154
        }
    }
}

#Preview {
    struct PreviewContainer: View {
        @State private var text1 = ""
        @State private var text2 = ""
        @State private var text3 = "test"
        @State private var isDisabled = false

        var body: some View {
            VStack(spacing: 16) {
                GimiTextEditor(
                    text: $text1,
                    type: .small,
                    placeholder: "Small",
                    isDisabled: false
                )
                GimiTextEditor(
                    text: $text2,
                    type: .medium,
                    placeholder: "Medium",
                    isDisabled: false
                )
                GimiTextEditor(
                    text: $text3,
                    type: .large,
                    placeholder: "Large",
                    isDisabled: isDisabled
                )

                Button(isDisabled ? "활성화하기" : "비활성화하기") {
                    isDisabled.toggle()
                }
                .padding()
                .background(isDisabled ? Color.green : Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding()
            .background(Color.gray600)
        }
    }

    return PreviewContainer()
}
