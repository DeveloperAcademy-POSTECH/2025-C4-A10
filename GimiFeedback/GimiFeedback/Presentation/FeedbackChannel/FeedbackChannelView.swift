import SwiftUI

struct FeedbackChannelView: View {
    
    @StateObject var viewModel: FeedbackChannelViewModel
    
    init(channelItem: FeedbackChannel) {
        _viewModel = StateObject(wrappedValue: FeedbackChannelViewModel(channelItem: channelItem))
    }
    
    var body: some View {
        VStack {
            Text(viewModel.channelItem.channelTitle)
            
            Text(viewModel.channelItem.content)
             
            List {
                if viewModel.feedbackList.isEmpty {
                    Text("등록된 피드백이 없습니다.")
                } else {
                    ForEach(viewModel.feedbackList) { item in
                        Text(item.writePerson)
                    }
                }
            }
        }
        .onAppear {
            viewModel.send(.fetchFeedbackList)
        }
    }
}
