//
//  FeedbackDetailViewModel.swift
//  GimiFeedback
//
//  Created by 조운경 on 7/15/25.
//

import Foundation

final class FeedbackDetailViewModel: ViewModelable {
    
    enum Action {
        case deleteFeedback
        case createDummyDetails
    }
    
    var feedbackItem: Feedback
    @Published private(set) var feedbackDetails: [FeedbackContent]
    @Published private(set) var errorMessage: String?
    @Published private(set) var isLoading: Bool = false
    
    @Published var isDeleted = false
    
    init(feedbackItem: Feedback) {
        self.feedbackItem = feedbackItem
        self.feedbackDetails = feedbackItem.content
    }
    
    func send(_ action: Action) {
        switch action {
        case .deleteFeedback:
            deleteFeedback(feedbackItem: feedbackItem)
        case .createDummyDetails:
            createDummyDetails()
        }
    }
}

extension FeedbackDetailViewModel {
    private func deleteFeedback(feedbackItem: Feedback) {
        Task {
            isLoading = true
            do {
                try await FirestoreManager.shared.delete(feedbackItem)
                print("피드백 삭제 성공")
                isDeleted = true
            } catch {
                errorMessage = "삭제 실패: \(error.localizedDescription)"
                print("삭제 실패: \(error.localizedDescription)")
            }
            isLoading = false
        }
    }
    
    // MARK: 테스트용 데이터 넣기
    private func createDummyDetails() {
        Task {
            do {
                let saved = try await FirestoreManager.shared.create(sampleFeedback)
                print("저장 성공: \(saved.id)")
            } catch {
                print("저장 실패: \(error.localizedDescription)")
            }
        }
    }
}
