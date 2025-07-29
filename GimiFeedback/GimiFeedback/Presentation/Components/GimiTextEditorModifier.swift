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

// MARK: - TextEditor 기본 생김새 부분

struct TextEditorBaseModifier: ViewModifier {
    let type: GimiTextEditorType
    @Environment(\.isEnabled) private var isEnabled

    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .padding(10)
            .padding(.trailing, 15)
            .background(backgroundColor)
            .scrollContentBackground(.hidden)
            .cornerRadius(12)
            .font(.body)
            .foregroundColor(textColor)
            .frame(height: editorHeight)
    }
    
    private var backgroundColor: Color {
        isEnabled ? .gray50 : .gray400
    }

    private var textColor: Color {
        isEnabled ? .gray900 : .white
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

// MARK: - 글자수 제한 부분

struct TextEditorLimitModifier: ViewModifier {
    @Binding var text: String
    let maximumText: Int

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottomTrailing) {
                Text("(\(text.count) / \(maximumText))")
                    .font(.system(size: 12))
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

// MARK: - 삭제 action 부분

struct TextEditorClearButtonModifier: ViewModifier {
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .topTrailing) {
                Button(action: action) {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray700)
                        .padding()
                }
            }
    }
}

// MARK: - PlaceHolder 부분

struct TextEditorPlaceholderModifier: ViewModifier {
    let placeholder: String
    @Binding var text: String

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .topLeading) {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundStyle(.gray100)
                        .font(.callout)
                        .padding(.top, 12)
                        .padding(.leading, 15)
                    
                }
            }
    }
}

// MARK: - Modifier 확장 부분

extension View {
    func textEditorBase(type: GimiTextEditorType) -> some View {
        self.modifier(TextEditorBaseModifier(type: type))
    }

    func textEditorLimit(text: Binding<String>, maximumText: Int) -> some View {
        self.modifier(TextEditorLimitModifier(text: text, maximumText: maximumText))
    }

    func textEditorClearButton(action: @escaping () -> Void) -> some View {
        self.modifier(TextEditorClearButtonModifier(action: action))
    }

    func textEditorPlaceholder(placeholder: String, text: Binding<String>) -> some View {
        self.modifier(TextEditorPlaceholderModifier(placeholder: placeholder, text: text))
    }
}

// MARK: - Preview 예시 부분

#Preview {
    struct PreviewContainer: View {
        @State private var texts = ["", "", "ㅇㅁㄴㅇㅁㄴㅇㅁㅇㅁㄴㅇㅁㄴㅇㅁㄴㅇㅁㄴㅇㅁㄴㅇㅁㄴㅇㅁㄴㅇㅁㄴㅇㅁㄴㅇㅁㄴㄴㅁㅇㅁㄴㅇㅁㄴㅇㄴㅁㅇㅁㄴㅇㅁㄴㅇㅁㄴㅇㅁㄴㅇㅁㄴㅇㅁㄴㅇㅁㄴㅇㅁㄴㅇㅁㄴㅇㅁㄴㅇㅁㄴㅇㅁㄴㅇㅁㄴㅇㅁㄴㅇㅁㄴㅇㅁㄴㅇㅁㄴ"]
        private let placeHolder = "PlaceHolder"
        @State private var isDisabled = false
        
        var body: some View {
            VStack(spacing: 16) {
                ForEach($texts.indices, id: \.self) { index in
                    TextEditor(text: $texts[index])
                        .textEditorBase(type: .medium)
                        .textEditorLimit(text: $texts[index], maximumText: 100)
                        .textEditorPlaceholder(placeholder: placeHolder, text: $texts[index])
                        .textEditorClearButton {
                            texts.remove(at: index)
                        }
                        .disabled(isDisabled)
                }
                Button("추가하기") {
                    texts.append("")
                }
                Button("Toggle Disabled") {
                    isDisabled.toggle()
                }
            }
            .padding()
            .background(Color.gray600)
        }
    }
    
    return PreviewContainer()
}
