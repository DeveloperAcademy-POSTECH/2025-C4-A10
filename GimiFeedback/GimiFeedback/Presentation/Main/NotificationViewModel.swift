//
//  MainViewModel.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/18/25.
//

import Foundation
import Combine

final class NotificationViewModel: ViewModelable {
    
    enum Action {
        case fetchFeedback
        case saveUserInfo(userInfo: [AnyHashable: Any])
        case resetFeedback
    }
    
    @Published private(set) var userInfo: [AnyHashable: Any]?
    @Published private(set) var feedback: Feedback?
    
    private var cancellables = Set<AnyCancellable>()
    
    init(userInfo: [AnyHashable: Any]? = nil) {
        self.userInfo = userInfo
        observePushNotification()
    }
    
    func send(_ action: Action) {
        switch action {
        case .fetchFeedback:
            if userInfo != nil {
                fetchFeedback()
            }
        case .saveUserInfo(let userInfo):
            self.userInfo = userInfo
        case .resetFeedback:
            feedback = nil
        }
    }
    
    private func observePushNotification() {
        NotificationCenter.default.publisher(for: Notification.Name("PushNavigation"))
            .sink { [weak self] notification in
                guard let userInfo = notification.userInfo else { return }
                
                self?.userInfo = userInfo
                self?.send(.fetchFeedback)
            }
            .store(in: &cancellables)
    }

    private func fetchFeedback() {
        guard let userInfo,
              let feedbackId = userInfo["feedbackId"] as? String else {
            print("유효하지 않은 알림 userInfo입니다.")
            return
        }
        
        Task {
            do {
                if let fetchFeedback: Feedback = try await FirestoreManager.shared.get(
                    feedbackId,
                    collectionType: .feedback
                ) {
                    self.feedback = fetchFeedback
                }
            } catch {
                print("Firestore 피드백 불러오기 실패: \(error)")
            }
        }
    }
}
