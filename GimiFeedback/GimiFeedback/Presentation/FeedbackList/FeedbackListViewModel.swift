import Foundation

final class FeedbackListViewModel: ViewModelable {
    
    enum Action {
        case fetchFeedbackChannelList
        case clearError
    }
    
    @Published private(set) var feedbackChannelList: [FeedbackChannel] = []
    @Published private(set) var errorMessage: String?
    @Published private(set) var isFeedbackChannelListLoading: Bool = false
    
    @Published private(set) var feedbackCount: [UUID: Int] = [:]
    @Published private(set) var visibleFeedbackCount: [UUID: Int] = [:]
    
    @Published private(set) var totalFeedbackCount: Int = .zero
    
    func send(_ action: Action) {
        switch action {
        case .fetchFeedbackChannelList:
            fetchFeedbackChannelList()
            
        case .clearError:
            errorMessage = nil
        }
    }
}

extension FeedbackListViewModel {
    private func fetchFeedbackChannelList() {
        Task {
            isFeedbackChannelListLoading = true
            
            totalFeedbackCount = .zero
            
            do {
                feedbackChannelList = try await FirestoreManager.shared.fetch(
                    as: FeedbackChannel.self,
                    .feedbackChannel
                )
                
                for channel in feedbackChannelList {
                    let feedbackList = try await FirestoreManager.shared.fetch(
                        as: Feedback.self,
                        .feedback,
                        whereFeild: "feedbackChannelID",
                        equalData: channel.id.uuidString
                    )
                    
                    feedbackCount[channel.id] = feedbackList.count
                    visibleFeedbackCount[channel.id] = feedbackList.filter { !$0.visiable }.count
                    
                    totalFeedbackCount += feedbackList.count
                }
            } catch {
                errorMessage = error.localizedDescription
            }
            isFeedbackChannelListLoading = false
        }
    }
}
