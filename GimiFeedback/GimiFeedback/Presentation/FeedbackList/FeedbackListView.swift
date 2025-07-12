import SwiftUI

struct FeedbackListView: View {
    @StateObject var viewModel: FeedbackListViewModel
    
    init() {
        _viewModel = StateObject(wrappedValue: FeedbackListViewModel())
    }
    
    private var isLoading: Bool {
        !viewModel.isFeedbackChannelListLoading
    }
    
    var body: some View {
        VStack {
            List {
                ForEach(viewModel.feedbackChannelList) { item in
                    VStack(alignment: .leading) {
                        Text("title: \(item.channelTitle)")
                        
                        if let total = viewModel.feedbackCount[item.id] {
                            Text("총 피드백 \(total)개")
                        }
                        
                        if let visibleFeedbackCount = viewModel.visibleFeedbackCount[item.id] {
                            Text("확인 되지 않은 피드백 \(visibleFeedbackCount)개")
                        }
                    }
                }
            }
        }
        .onAppear {
            viewModel.send(.fetchFeedbackChannelList)
        }
    }
}

#Preview {
    FeedbackListView()
}
