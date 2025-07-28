//
//  FeedbackWrite+WriteView.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/27/25.
//

import SwiftUI

extension FeedbackWriteView {
    struct WriteView: View {
        @Binding var content: [String]
        
        var contentType: FeedbackContentType
        
        @State private var showDeleteAlert: Bool = false
        @State private var indexToDelete: Int?
        
        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                Text(contentType.title)
                    .font(.title1)
                Text(contentType.content)
                    .font(.footnote)
                    .foregroundColor(.gray600)
                ForEach(content.indices, id: \.self) { index in
                    TextEditor(text: $content[index])
                        .textEditorBase(type: .medium)
                        .textEditorPlaceholder(placeholder: "최소 10자 이상 작성해주세요", text: $content[index])
                        .textEditorClearButton {
                            indexToDelete = index
                            showDeleteAlert = true
                        }
                        .textEditorLimit(text: $content[index], maximumText: 300)
                }
                
                if content.count < 3 {
                    Button {
                        content.append("")
                    } label: {
                        AddItemButtonLabel()
                    }
                }
            }
            .alert("항목 삭제하기", isPresented: $showDeleteAlert) {
                Button("취소", role: .cancel) { }
                Button("확인", role: .destructive) {
                    if let index = indexToDelete {
                        content.remove(at: index)
                    }
                }
            } message: {
                Text("해당 항목을 삭제하시겠습니까?")
            }
        }
    }
}

extension FeedbackWriteView {
    struct AddItemButtonLabel: View {
        var body: some View {
            HStack(spacing: 4) {
                Image(systemName: "plus")
                    .resizable()
                    .frame(width: 12, height: 12)
                Text("항목 추가하기")
                    .font(.footnote)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .foregroundColor(.black)
            .background(.gray50)
            .cornerRadius(12)
        }
    }
}

#Preview {
    VStack {
        FeedbackWriteView.WriteView(content: .constant([""]), contentType: .typeContinue)
        
        FeedbackWriteView.WriteView(content: .constant(["test"]), contentType: .typeStop)
    }
    .customPadding()
}
