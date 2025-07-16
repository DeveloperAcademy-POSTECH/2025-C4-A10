//
//  FeedbackDetailViewModel.swift
//  GimiFeedback
//
//  Created by 조운경 on 7/15/25.
//

import Foundation

final class FeedbackDetailViewModel: ViewModelable {
    
    enum Action {
        case fetchDetails
        case deleteFeedback
        case visualizeDetail
    }
    
    var feedback: Feedback
    
    init(feedback: Feedback) {
        self.feedback = feedback
    }
    
    func send(_ action: Action) {
        switch action {
        case .fetchDetails:
            fetchDetails(feedbackID: feedback.id)
            
        case .deleteFeedback:
            deleteFeedback(feedbackID: feedback.id)
            
        case .visualizeDetail:
            
            
        }
    }
}

extension FeedbackDetailViewModel {
    func fetchDetails(feedbackID: UUID) {
        
    }
    
    func deleteFeedback(feedbackID: UUID) {
        
    }
    
    func visualizeDetail(detailID: UUID) {
        
    }
}
