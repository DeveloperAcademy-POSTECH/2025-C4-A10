import Foundation

final class FeedbackChannelViewModel: ViewModelable {
    
    enum Action {
        case fetchFeedbackList
        case clearError
    }
    
    let channelItem: FeedbackChannel
    
    @Published private(set) var feedbackList: [Feedback] = []
    @Published private(set) var errorMessage: String?
    @Published private(set) var isLoading: Bool = false
    
    init(channelItem: FeedbackChannel) {
        self.channelItem = channelItem
    }
    
    func send(_ action: Action) {
        switch action {
        case .fetchFeedbackList:
            fetchFeedbackList(channelID: channelItem.id)
            
        case .clearError:
            errorMessage = nil
            
        }
    }
}

extension FeedbackChannelViewModel {
    private func fetchFeedbackList(channelID: UUID) {
        Task {
            isLoading = true
            do {
                feedbackList = try await FirestoreManager.shared.fetch(
                    as: Feedback.self, .feedback,
                    whereFeild: "feedbackChannelID",
                    equalData: channelID.uuidString)
            } catch {
                errorMessage = error.localizedDescription
            }
            
            isLoading = false
        }
    }
    
}
