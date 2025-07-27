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
    let nickName: String
    @Published var continues: [String] = [""]
    @Published var stops: [String] = [""]
    
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?
    
    private(set) var createdFeedback: Feedback?
    
    var canCreate: Bool {
        let isValidContinue = continues.contains {
            $0.trimmingCharacters(in: .whitespacesAndNewlines).count >= 10
        }
        let isValidStop = stops.contains {
            $0.trimmingCharacters(in: .whitespacesAndNewlines).count >= 10
        }
        return isValidContinue || isValidStop
    }
    
    init(feedbackChannel: FeedbackChannel, nickName: String) {
        self.feedbackChannel = feedbackChannel
        self.nickName = nickName
    }
    
    func send(_ action: Action) {
        switch action {
        case .feedbackWrite:
            let feedbackContents = createContent()
            
            print("생성된 피드백 콘텐츠:", feedbackContents)
            
            let createdFeedback = Feedback(
                feedbackChannelID: feedbackChannel.id,
                readPerson: feedbackChannel.userID,
                writePerson: nickName,
                content: feedbackContents
            )
            
            saveFeedbackToFirestore(to: createdFeedback)
            
            FCMManager.shared.sendNotification(
                to: feedbackChannel.userID,
                from: nickName,
                title: feedbackChannel.channelTitle,
                feedbackId: createdFeedback.id.uuidString
            )
        }
    }
    
    private func createContent() -> [FeedbackContent] {
        var result: [FeedbackContent] = []
        
        result += continues
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map { FeedbackContent(content: $0, spicy: 3, type: .typeContinue)}
        
        result += stops
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map { FeedbackContent(content: $0, spicy: 3, type: .typeStop) }
        
        return result
    }
    
    private func saveFeedbackToFirestore(to feedback: Feedback) {
        Task {
            isLoading = true
            do {
                let saveFeedback = try await FirestoreManager.shared.create(feedback)
                
                createdFeedback = saveFeedback
            } catch {
                print("생성을 실패했습니다 \(error.localizedDescription)")
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
    
}
