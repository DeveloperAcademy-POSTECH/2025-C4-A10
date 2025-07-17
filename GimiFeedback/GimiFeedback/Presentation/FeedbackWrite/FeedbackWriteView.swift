//
//  FeedbackWriteView.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/15/25.
//

import SwiftUI

struct FeedbackWriteView: View {
    @StateObject var viewModel: FeedbackWriteViewModel
    
    init(feedbackChannel: FeedbackChannel) {
        _viewModel = StateObject(
            wrappedValue: .init(
                feedbackChannel: feedbackChannel
            )
        )
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(viewModel.feedbackChannel.channelTitle)
                Text(viewModel.feedbackChannel.content)
                
                Text("닉네임")
                Text("받는 사람에게 보여지는 닉네임입니다.")
                TextField("", text: $viewModel.nickName)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(5)
                
                FeedbackContentView(content: $viewModel.keeps, contentType: .keep)
                FeedbackContentView(content: $viewModel.problems, contentType: .problem)
                FeedbackContentView(content: $viewModel.trys, contentType: .try)
                FeedbackContentView(content: $viewModel.others, contentType: .other)
            }
        }
        .padding()
        .navigationTitle("피드백 작성하기")
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension FeedbackWriteView {
    struct FeedbackContentView: View {
        @Binding var content: [String]
        
        var contentType: FeedbackContentType
        
        var body: some View {
            Text(contentType.title)
            Text(contentType.content)
            ForEach(content.indices, id: \.self) { index in
                TextField("", text: $content[index])
                    .frame(height: 102)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(5)
            }
            
            if content.count < 3 {
                Button {
                    content.append("")
                } label: {
                    Text("+ 항목 추가하기")
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .foregroundColor(.black)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(12)
                }
                .padding(.top, 8)
            }
        }
    }
}

#Preview {
    let feedbackChannel = FeedbackChannel(
        userID: "Test",
        channelTitle: "Test",
        content: "Test"
    )
    
    FeedbackWriteView(feedbackChannel: feedbackChannel)
}
