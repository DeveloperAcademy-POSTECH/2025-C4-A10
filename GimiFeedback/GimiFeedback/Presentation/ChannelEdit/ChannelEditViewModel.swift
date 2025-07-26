//
//  ChannelEditViewModel.swift
//  GimiFeedback
//
//  Created by 승찬 on 7/21/25.
//

import Foundation

final class ChannelEditViewModel: ViewModelable {

    enum Action {
        case updateFeedbackChannel
    }
    
    @Published var channelItem: FeedbackChannel
    @Published private(set) var isLoading: Bool = false
    @Published var isUpdate = false
    
    let originalChannelTitle: String
    let originalContent: String
    
    var isActive: Bool {
        // 제목은 비어있으면 안됌
        let trimmed = channelItem.channelTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }

        /// 이전과 하나라도 다른 값이어야 함
        return channelItem.channelTitle != originalChannelTitle
        || channelItem.content != originalContent
    }

    init(channelItem: FeedbackChannel) {
        self.channelItem = channelItem
        originalChannelTitle = channelItem.channelTitle
        originalContent = channelItem.content
    }

    func send(_ action: Action) {
        switch action {
        case .updateFeedbackChannel:
            updateFeedbackChannel()
        }
    }
}

extension ChannelEditViewModel {
    private func updateFeedbackChannel() {
        guard !channelItem.channelTitle.isEmpty else { return }
        
        Task {
            isLoading = true
            
            let newChannel = FeedbackChannel(
                id: channelItem.id,
                userID: FirebaseAuthManager.currentUserID,
                userName: FirebaseAuthManager.userNickName,
                channelTitle: channelItem.channelTitle,
                content: channelItem.content)
            
            do {
                try await FirestoreManager.shared.update(newChannel)
                channelItem = newChannel
                isUpdate = true
            } catch {
                print("저장 실패: \(error.localizedDescription)")
            }
            
            isLoading = false
        }
    }
}
