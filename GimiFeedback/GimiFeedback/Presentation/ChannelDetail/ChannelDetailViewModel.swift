import Foundation

final class ChannelDetailViewModel: ViewModelable {
    
    enum Action {
        case getFeedbackChannelItem
        case fetchFeedbackList
        case deleteChannel
        case shareToKakao(String)
        case clearError
    }
    
    @Published var channelItem: FeedbackChannel
    
    @Published private(set) var feedbackList: [Feedback] = []
    @Published private(set) var errorMessage: String?
    @Published private(set) var isChannelItem: Bool = false
    @Published private(set) var isFeedbackListLoading: Bool = false
    @Published private(set) var isDeleteChannelLoading: Bool = false
    
    @Published var isDelete = false

    var isLoading: Bool {
        isChannelItem
        || isFeedbackListLoading
        || isDeleteChannelLoading
    }
    
    init(channelItem: FeedbackChannel) {
        self.channelItem = channelItem
    }
    
    func send(_ action: Action) {
        switch action {
        case .getFeedbackChannelItem:
            getFeedbackChannelItem()
            
        case .fetchFeedbackList:
            fetchFeedbackList(channelID: channelItem.id)
            
        case .deleteChannel:
            deleteChannel(channelItem: channelItem)
            
        case .shareToKakao(let channelID):
            KakaoShareManager.shared.shareToKakao(channelID: channelID)
            
        case .clearError:
            errorMessage = nil
            
        }
    }
}

extension ChannelDetailViewModel {
    private func getFeedbackChannelItem() {
        Task {
            isChannelItem = true
            do {
                guard let update: FeedbackChannel = try await FirestoreManager.shared.get(
                    channelItem.id.uuidString,
                    collectionType: .feedbackChannel)
                else { return }
                channelItem = update
                
            } catch {
                errorMessage = error.localizedDescription
            }
            isChannelItem = false
        }
    }
    
    private func fetchFeedbackList(channelID: UUID) {
        Task {
            isFeedbackListLoading = true
            do {
                feedbackList = try await FirestoreManager.shared.fetch(
                    as: Feedback.self, .feedback,
                    whereFeild: "feedbackChannelID",
                    equalData: channelID.uuidString)
            } catch {
                errorMessage = error.localizedDescription
            }
            
            isFeedbackListLoading = false
        }
    }
    
    private func deleteChannel(channelItem: FeedbackChannel) {
        Task {
            isDeleteChannelLoading = true
            do {
                for feedback in feedbackList {
                    try await FirestoreManager.shared.delete(feedback)
                }
                
                try await FirestoreManager.shared.delete(channelItem)
                isDelete = true
            } catch {
                errorMessage = error.localizedDescription
            }
            isDeleteChannelLoading = false
        }
    }
}
