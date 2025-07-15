import Foundation

final class FeedbackChannelViewModel: ViewModelable {
    
    enum Action {
        case fetchFeedbackList
        case deleteFeedbackChannel
        case clearError
    }
    
    let channelItem: FeedbackChannel
    
    @Published private(set) var feedbackList: [Feedback] = []
    @Published private(set) var errorMessage: String?
    @Published private(set) var isLoading: Bool = false
    
    @Published var isDelete = false
    
    init(channelItem: FeedbackChannel) {
        self.channelItem = channelItem
    }
    
    func send(_ action: Action) {
        switch action {
        case .fetchFeedbackList:
            fetchFeedbackList(channelID: channelItem.id)

        case .deleteFeedbackChannel:
            deleteFeedbackChannel(channelItem: channelItem)
            
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
    
    func deleteFeedbackChannel(channelItem: FeedbackChannel) {
        
        Task {
            isLoading = true
            do {
                for feedback in feedbackList {
                    try await FirestoreManager.shared.delete(feedback)
                }
                
                try await FirestoreManager.shared.delete(channelItem)
                isDelete = true
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
            
        }
    }
}
