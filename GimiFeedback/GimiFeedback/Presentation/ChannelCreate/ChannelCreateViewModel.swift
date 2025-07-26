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
    }

    @Published var title: String = ""
    @Published var description: String = ""
    @Published var createdChannelID: String?
    var buttonDisabled: Bool {
        title.isEmpty
    }
    var messageContent: String {
        description.isEmpty ? "입력한 정보로 채널을 생성합니다\n설명이 없다면 기본 문구가 사용돼요." : "입력한 정보로 채널을 생성합니다."
    }

    @Published private(set) var isLoading: Bool = false

    func send(_ action: Action) {
        switch action {
        case .createFeedbackChannel:
            createFeedbackChannel()
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
}
