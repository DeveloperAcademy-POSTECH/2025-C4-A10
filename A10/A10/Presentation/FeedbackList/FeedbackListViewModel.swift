//
//  FeedbackListViewModel.swift
//  A10
//
//  Created by 김민석 on 7/8/25.
//

import Foundation

final class FeedbackListViewModel: ViewModelable {
    
    enum Action {
        case load
    }
    
    @Published private(set) var Feedbacks: [String] = []
    
    func send(_ action: Action) {
        switch action {
        case .load:
            print("hello")
        }
    }
}
