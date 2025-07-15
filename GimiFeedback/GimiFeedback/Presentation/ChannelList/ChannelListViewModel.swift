import Foundation

final class ChannelListViewModel: ViewModelable {
    
    enum Action {
        case fetchChannelList
        case clearError
    }
    
    @Published private(set) var channelList: [FeedbackChannelInfo] = []
    @Published private(set) var totalFeedbackCount: Int = .zero
    
    @Published private(set) var errorMessage: String?
    @Published private(set) var isChannelListLoading: Bool = false
    
    func send(_ action: Action) {
        switch action {
        case .fetchChannelList:
            fetchChannelList()
            
        case .clearError:
            errorMessage = nil
        }
    }
}

extension ChannelListViewModel {
    private func fetchChannelList() {
        Task {
            isChannelListLoading = true
            
            totalFeedbackCount = .zero
            
            do {
                let channels = try await FirestoreManager.shared.fetch(
                    as: FeedbackChannel.self,
                    .feedbackChannel
                )
                
                var result: [FeedbackChannelInfo] = []
                
                for channel in channels {
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
                
                channelList = result
                
            } catch {
                errorMessage = error.localizedDescription
            }
            isChannelListLoading = false
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
