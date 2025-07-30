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
        case updateFeedbackVisibility
        case transContent(FeedbackContent)
        case updateCardState(FeedbackContent)
    }
    
    var feedbackItem: Feedback
    @Published var continueFeedbackList: [FeedbackContent]
    @Published var stopFeedbackList: [FeedbackContent]
    @Published private(set) var errorMessage: String?
    @Published var isDeleted = false
    @Published var isShowToast = false
    
    @Published private(set) var isDeleteLoading: Bool = false
    @Published private(set) var isTransLoading: Bool = false
    @Published private(set) var isUpdateCardStateLoading: Bool = false
    @Published private(set) var isUpdateVisibleLoading: Bool = false
    
    var isLoading: Bool {
        isDeleteLoading
        || isUpdateVisibleLoading
    }
    
    init(feedbackItem: Feedback) {
        self.feedbackItem = feedbackItem
        self.continueFeedbackList = feedbackItem.content.filter { $0.type == .typeContinue }
        self.stopFeedbackList = feedbackItem.content.filter { $0.type == .typeStop }
    }
    
    func send(_ action: Action) {
        switch action {
        case .deleteFeedback:
            deleteFeedback(feedbackItem: feedbackItem)
        case .updateFeedbackVisibility:
            feedbackItem.visiable = true
            updateFeedbackVisibility()
        case .transContent(let content):
            transFeedbackContent(content: content)
        case .updateCardState(let detail):
            updateCardState(detail: detail)
        }
    }
}

extension FeedbackDetailViewModel {
    private func deleteFeedback(feedbackItem: Feedback) {
        Task {
            isDeleteLoading = true
            do {
                try await FirestoreManager.shared.delete(feedbackItem)
                print("피드백 삭제 성공")
                isDeleted = true
            } catch {
                errorMessage = "삭제 실패: \(error.localizedDescription)"
                print("삭제 실패: \(error.localizedDescription)")
            }
            isDeleteLoading = false
        }
    }
    
    private func transFeedbackContent(content: FeedbackContent) {
        Task {
            isTransLoading = true
            let response = try await GPTManger.shared.sendChatCompletion(inputText: content.content)
                    
            guard let index = feedbackItem.content.firstIndex(where: { $0.id == content.id }) else { return }
            
            feedbackItem.content[index].transContent = response
            
            continueFeedbackList = feedbackItem.content.filter { $0.type == .typeContinue }
            stopFeedbackList = feedbackItem.content.filter { $0.type == .typeStop }
            do {
                try await FirestoreManager.shared.update(feedbackItem)
            } catch {
                errorMessage = "원문 표시 실패: \(error.localizedDescription)"
                print("원문 표시 실패: \(error.localizedDescription)")
            }
            isTransLoading = false
        }
    }
    
    private func updateCardState(detail: FeedbackContent) {
        guard let index = feedbackItem.content.firstIndex(where: { $0.id == detail.id }) else { return }
        
        feedbackItem.content[index].cardState = detail.cardState
        
        continueFeedbackList = feedbackItem.content.filter { $0.type == .typeContinue }
        stopFeedbackList = feedbackItem.content.filter { $0.type == .typeStop }
        
        Task {
            isUpdateCardStateLoading = true
            do {
                try await FirestoreManager.shared.update(feedbackItem)
            } catch {
                errorMessage = "원문 표시 실패: \(error.localizedDescription)"
                print("원문 표시 실패: \(error.localizedDescription)")
            }
            isUpdateCardStateLoading = false
        }
    }
    
    private func updateFeedbackVisibility() {
           Task {
               isUpdateVisibleLoading = true
               do {
                   try await FirestoreManager.shared.update(feedbackItem)
               } catch {
                   errorMessage = "원문 표시 실패: \(error.localizedDescription)"
                   print("원문 표시 실패: \(error.localizedDescription)")
               }
               isUpdateVisibleLoading = false
           }
       }
}
