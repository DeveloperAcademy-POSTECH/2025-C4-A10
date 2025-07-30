import Foundation

final class ChannelListViewModel: ViewModelable {
    
    enum Action {
        case fetchChannelList
        case clearError
        case channelGuideUpdate
    }
    
    @Published private(set) var channelList: [FeedbackChannelInfo] = []
    @Published private(set) var totalFeedbackCount: Int = .zero
    @Published private(set) var isShowToast = UserDefaults.standard.bool(for: .channelGuideToast)
    
    @Published private(set) var errorMessage: String?
    @Published private(set) var isChannelListLoading: Bool = false
    
    func send(_ action: Action) {
        switch action {
        case .fetchChannelList:
            fetchChannelList()
            
        case .clearError:
            errorMessage = nil
        case .channelGuideUpdate:
            isShowToast = true
            UserDefaults.standard.save(true, for: .channelGuideToast)
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
                print(error.localizedDescription)
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
                    visiableFeedback: feedbackList.contains(where: { !$0.visiable })
                )
            )
            
            totalFeedbackCount += feedbackList.count
        }
        
        return result
    }
}

struct FeedbackChannelInfo: Identifiable {
    let channel: FeedbackChannel
    let feedbackCount: Int
    let visiableFeedback: Bool
    
    var id: UUID {
        channel.id
    }
    
    var folderImageString: String {
        let count = max(0, min(feedbackCount, 4))
        if count == 0 { // swiftlint:disable:this empty_count
            return "Folder-0"
        }
        let visiable = visiableFeedback ? "False" : "True"
        return "Folder-\(count)-\(visiable)"
    }
}
