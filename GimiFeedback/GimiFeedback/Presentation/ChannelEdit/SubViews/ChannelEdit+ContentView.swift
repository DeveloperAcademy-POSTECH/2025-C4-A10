//
//  ChannelEdit+ContentView.swift
//  GimiFeedback
//
//  Created by 승찬 on 7/24/25.
//

import SwiftUI

extension ChannelEditView {
    struct ContentView: View {
        @Binding var text: String
        let field: FocusField
        var focusState: FocusState<FocusField?>.Binding
        
        var body: some View {
            VStack(alignment: .leading, spacing: 2) {
                Text("설명")
                    .font(.title1)
                    .foregroundStyle(.black)
                
                Text("피드백을 받고 싶은 내용에 대해 설명해주세요")
                    .font(.footnote)
                    .foregroundStyle(.gray400)
                
                TextEditor(text: $text)
                    .textEditorBase(type: .large)
                    .textEditorLimit(text: $text, maximumText: 100)
                    .textEditorPlaceholder(placeholder: "자유롭게 피드백을 남겨주세요", text: $text)
                    .padding(.top, 10)
                    .focused(focusState, equals: field)
            }
        }
    }
}
