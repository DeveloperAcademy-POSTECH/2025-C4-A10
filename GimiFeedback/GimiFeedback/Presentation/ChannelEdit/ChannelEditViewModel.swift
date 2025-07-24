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
