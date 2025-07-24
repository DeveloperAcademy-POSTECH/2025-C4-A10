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
    @Published private(set) var isLoading: Bool = false
    
    @Published var isDelete = false
    
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
            isLoading = true
            do {
                guard let update: FeedbackChannel = try await FirestoreManager.shared.get(
                    channelItem.id.uuidString,
                    collectionType: .feedbackChannel)
                else { return }
                channelItem = update
                
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = true
        }
    }
    
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
    
    private func deleteChannel(channelItem: FeedbackChannel) {
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

struct FeedbackContentCount {
    let keep: Int
    let problem: Int
    let `try`: Int
    
    var formattedText: String {
        var itemList: [String] = []
        
        if keep > .zero {
            itemList.append("Keep \(keep)")
        }
        
        if problem > .zero {
            itemList.append("Problem \(problem)")
        }
        
        if `try` > .zero {
            itemList.append("Try \(`try`)")
        }
        
        return itemList.joined(separator: ", ")
    }
}

extension Feedback {
    var contentCount: FeedbackContentCount {
        let keep = content.filter { $0.type == .keep }.count
        let problem = content.filter { $0.type == .problem }.count
        let `try` = content.filter { $0.type == .try }.count
        return FeedbackContentCount(keep: keep, problem: problem, try: `try`)
    }
}
