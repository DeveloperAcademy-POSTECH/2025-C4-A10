//
//  FeedbackWriteViewModel.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/16/25.
//

import Foundation

final class FeedbackWriteViewModel: ViewModelable {
    enum Action {
        case feedbackWrite
    }
    
    let feedbackChannel: FeedbackChannel
    @Published var nickName: String = ""
    @Published var keeps: [String] = [""]
    @Published var problems: [String] = [""]
    @Published var trys: [String] = [""]
    @Published var others: [String] = [""]
    
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
