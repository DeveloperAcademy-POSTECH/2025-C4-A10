//
//  ChannelCreateViewModel.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/14/25.
//

import Foundation

final class ChannelCreateViewModel: ViewModelable {

    enum Action {
        case createFeedbackChannel
        case verifyTitleEmpty
        case setMessageContent
    }

    @Published var title: String = ""
    @Published var description: String = ""
    @Published var createdChannelID: String?
    @Published var buttonDisabled: Bool = true
    @Published var messageContent: String = "입력한 정보로 채널을 생성합니다"

    @Published private(set) var isLoading: Bool = false

    func send(_ action: Action) {
        switch action {
        case .createFeedbackChannel:
            createFeedbackChannel()
        case .verifyTitleEmpty:
            verifyTitleEmpty()
        case .setMessageContent:
            setMessageContent()
        }
    }
}

extension ChannelCreateViewModel {
    private func createFeedbackChannel() {
        guard !title.isEmpty else { return }
        
        Task {
            isLoading = true
            
            let newChannel = FeedbackChannel(
                userID: FirebaseAuthManager.currentUserID,
                channelTitle: title,
                content: description.isEmpty ? "자유롭게 피드백을 남겨주세요" : description
            )
            
            do {
                _ = try await FirestoreManager.shared.create(newChannel)
                print("채널 저장 완료")
                createdChannelID = newChannel.id.uuidString
            } catch {
                print("저장 실패: \(error.localizedDescription)")
            }
            
            isLoading = false
        }
    }
    
    private func verifyTitleEmpty() {
        if title.isEmpty {
            buttonDisabled = true
        } else {
            buttonDisabled = false
        }
    }
    
    private func setMessageContent() {
        if description.isEmpty {
            messageContent += "\n설명이 없다면 기본 문구가 사용돼요."
        }
        else {
            messageContent = "입력한 정보로 채널을 생성합니다."
        }
    }
}
