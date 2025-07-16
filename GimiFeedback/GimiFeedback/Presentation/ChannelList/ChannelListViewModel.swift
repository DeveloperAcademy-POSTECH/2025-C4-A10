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
            do {
                let filteredChannels = try await FirestoreManager.shared.fetch(
                    as: FeedbackChannel.self, .feedbackChannel,
                    whereFeild: "userID",
                    equalData: FirebaseAuthManager.currentUserID)
                
                let filteredItemList = try await fetchFilteredChannelList(itemList: filteredChannels)
                
                channelList = filteredItemList
                
            } catch {
                errorMessage = error.localizedDescription
            }
            isChannelListLoading = false
        }
    }
    
    private func fetchFilteredChannelList(itemList: [FeedbackChannel]) async throws -> [FeedbackChannelInfo] {
        var result: [FeedbackChannelInfo] = []
        totalFeedbackCount = .zero
        
        for channel in itemList {
            let feedbackList = try await FirestoreManager.shared.fetch(
                as: Feedback.self,
                .feedback,
                whereFeild: "feedbackChannelID",
                equalData: channel.id.uuidString)
            
            result.append(
                FeedbackChannelInfo(
                    channel: channel,
                    feedbackCount: feedbackList.count,
                    visibleFeedbackCount: feedbackList.filter({ !$0.visiable }).count))
            
            totalFeedbackCount += feedbackList.count
        }
        
        return result
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
