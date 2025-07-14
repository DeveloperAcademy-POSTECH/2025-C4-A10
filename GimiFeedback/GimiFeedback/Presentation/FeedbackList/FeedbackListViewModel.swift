import Foundation

final class FeedbackListViewModel: ViewModelable {
    
    enum Action {
        case fetchFeedbackChannelList
        case clearError
    }
    
    @Published private(set) var feedbackChannelList: [FeedbackChannelInfo] = []
    @Published private(set) var totalFeedbackCount: Int = .zero
    
    @Published private(set) var errorMessage: String?
    @Published private(set) var isFeedbackChannelListLoading: Bool = false
    
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
    private func fetchFeedbackChannelList(){
        Task {
            isFeedbackChannelListLoading = true
            
            totalFeedbackCount = .zero
            
            do {
                let channelList = try await FirestoreManager.shared.fetch(
                    as: FeedbackChannel.self,
                    .feedbackChannel
                )
                
                var result: [FeedbackChannelInfo] = []
                
                for channel in channelList {
                    let feedbackList = try await FirestoreManager.shared.fetch(
                        as: Feedback.self,
                        .feedback,
                        whereFeild: "feedbackChannelID",
                        equalData: channel.id.uuidString
                    )
                    
                    result.append(
                        FeedbackChannelInfo(
                            channel: channel,
                            feedbackCount: feedbackList.count,
                            visibleFeedbackCount: feedbackList.filter({ !$0.visiable }).count)
                    )
                    
                    totalFeedbackCount += feedbackList.count
                }
                
                feedbackChannelList = result
                
            } catch {
                errorMessage = error.localizedDescription
            }
            isFeedbackChannelListLoading = false
        }
    }
}

struct FeedbackChannelInfo: Identifiable {
    let channel: FeedbackChannel
    let feedbackCount: Int
    let visibleFeedbackCount: Int
    
    var id: UUID {
        channel.id
    }
}
