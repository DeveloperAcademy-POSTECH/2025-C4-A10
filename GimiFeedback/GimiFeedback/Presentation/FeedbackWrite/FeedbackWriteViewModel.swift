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
    
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?
    
    private(set) var createdFeedback: Feedback?
    
    var canCreate: Bool {
        let isNickNameFilled = !nickName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let isAnyFieldFilled = keeps.contains(where: { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) ||
                               problems.contains(where: { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) ||
                               trys.contains(where: { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty })
        return isNickNameFilled && isAnyFieldFilled
    }
    
    init(feedbackChannel: FeedbackChannel) {
        self.feedbackChannel = feedbackChannel
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
            
        }
    }
    
    private func createContent() -> [FeedbackContent] {
        var result: [FeedbackContent] = []
        
        result += keeps
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map { FeedbackContent(content: $0, spicy: 3, type: .keep)}
        
        result += problems
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map { FeedbackContent(content: $0, spicy: 3, type: .problem) }
        
        result += trys
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map { FeedbackContent(content: $0, spicy: 3, type: .try) }
        
        result += others
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map { FeedbackContent(content: $0, spicy: 3, type: .other) }
        
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
