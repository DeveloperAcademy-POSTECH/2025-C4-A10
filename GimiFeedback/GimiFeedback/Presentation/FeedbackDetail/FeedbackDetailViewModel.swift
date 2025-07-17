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
        case visualizeDetail(detail: FeedbackContent)
    }
    
    var feedbackItem: Feedback
    @Published var keepFeedback: [FeedbackContent]
    @Published var problemFeedback: [FeedbackContent]
    @Published var tryFeedback: [FeedbackContent]
    @Published private(set) var errorMessage: String?
    @Published private(set) var isLoading: Bool = false
    
    @Published var isDeleted = false
    
    init(feedbackItem: Feedback) {
        self.feedbackItem = feedbackItem
        self.keepFeedback = feedbackItem.content.filter { $0.type == .keep }
        self.problemFeedback = feedbackItem.content.filter { $0.type == .problem }
        self.tryFeedback = feedbackItem.content.filter { $0.type == .try }
    }
    
    func send(_ action: Action) {
        switch action {
        case .deleteFeedback:
            deleteFeedback(feedbackItem: feedbackItem)
        case .createDummyDetails:
            createDummyDetails()
        case .visualizeDetail(let detail):
            updateVisibility(detail: detail)
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
    
    private func updateVisibility(detail: FeedbackContent) {
        guard let index = feedbackItem.content.firstIndex(where: { $0.id == detail.id }) else { return }
        
        feedbackItem.content[index].visiable = true
        
        keepFeedback = feedbackItem.content.filter { $0.type == .keep }
        problemFeedback = feedbackItem.content.filter { $0.type == .problem }
        tryFeedback = feedbackItem.content.filter { $0.type == .try }
        
        Task {
            isLoading = true
            do {
                try await FirestoreManager.shared.update(feedbackItem)
            } catch {
                errorMessage = "원문 표시 실패: \(error.localizedDescription)"
                print("원문 표시 실패: \(error.localizedDescription)")
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
