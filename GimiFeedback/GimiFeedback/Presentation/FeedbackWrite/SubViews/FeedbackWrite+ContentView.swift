//
//  FeedbackWrite+ContentView.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/26/25.
//

import SwiftUI

extension FeedbackWriteView {
    struct WriteContentView: View {
        let feedbackChannel: FeedbackChannel
        
        var body: some View {
            VStack(alignment: .leading, spacing: 6) {
                Text(feedbackChannel.channelTitle)
                    .font(.title2)
                    .foregroundColor(.gray700)
                Text(feedbackChannel.content)
                    .font(.footnote)
                    .foregroundColor(.gray600)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 2)
        }
    }
}

#Preview {
    VStack {
        FeedbackWriteView.WriteContentView(
            feedbackChannel: .init(
                userID: "Test",
                userName: "Test",
                channelTitle: "Challenge4",
                content: "코드에 대한 피드백을 위주로 부탁드려요.\n팀 협업과, 커뮤니케이션에 대한 피드백은 궁금하지 않아요."
            )
        )
        
        FeedbackWriteView.WriteContentView(
            feedbackChannel: .init(
                userID: "Test",
                userName: "Test",
                channelTitle: "Test",
                content: "Test"
            )
        )
    }
    .customPadding()
}
