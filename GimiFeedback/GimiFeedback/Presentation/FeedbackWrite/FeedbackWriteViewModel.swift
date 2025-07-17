//
//  FeedbackWriteViewModel.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/16/25.
//

final class FeedbackWriteViewModel: ViewModelable {
    enum Action {
        case feedbackWrite
    }
    
    let feedbackChannel: FeedbackChannel
    
    init(feedbackChannel: FeedbackChannel) {
        self.feedbackChannel = feedbackChannel
    }
    
    func send(_ action: Action) {
        switch action {
        case .feedbackWrite:
            print("Write")
        }
    }
    
}
