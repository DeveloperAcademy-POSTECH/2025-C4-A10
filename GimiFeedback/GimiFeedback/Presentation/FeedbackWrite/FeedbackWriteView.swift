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
        Text(viewModel.feedbackChannel.channelTitle)
        Text(viewModel.feedbackChannel.content)
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
