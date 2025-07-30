//
//  DescriptionView.swift
//  GimiFeedback
//
//  Created by 조운경 on 7/26/25.
//

import SwiftUI

extension ChannelCreateView {
    struct DescriptionView: View {
        @Binding var description: String
        
        var body: some View {
            VStack(alignment: .leading, spacing: 2) {
                Text("설명")
                    .font(.title1)
                
                Text("피드백을 받고 싶은 내용에 대해 설명해주세요")
                    .font(.footnote)
                    .foregroundColor(.gray400)
                    .padding(.bottom, 10)
                
                TextEditor(text: $description)
                    .textEditorBase(type: .large)
                    .textEditorLimit(text: $description, maximumText: 100)
                    .textEditorPlaceholder(placeholder: "자유롭게 피드백을 남겨주세요", text: $description)
            }
            .padding(.vertical, 16)
        }
    }
}

#Preview {
    ChannelCreateView.DescriptionView(description: .constant("1234"))
}
