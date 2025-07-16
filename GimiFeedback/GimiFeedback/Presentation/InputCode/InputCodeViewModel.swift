//
//  InputCodeViewModel.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/16/25.
//

import Foundation

final class InputCodeViewModel: ViewModelable {
    enum Action {
        case verifyCode
    }
    
    @Published var code: String = ""
    @Published private(set) var feedbackChannel: FeedbackChannel?
    @Published private(set) var errorMessage: String?
    
    func send(_ action: Action) {
        switch action {
        case .verifyCode:
            verifyCode()
        }
    }
    
    private func verifyCode() {
        Task {
            do {
                errorMessage = nil
                
                if let getFeedbackChannel: FeedbackChannel = try await
                    FirestoreManager.shared.get(
                        code, collectionType: .feedbackChannel
                ) {
                    feedbackChannel = getFeedbackChannel
                }
            } catch {
                print("코드 검증 실패: \(error.localizedDescription)")
                errorMessage = error.localizedDescription
            }
        }
    }
}
