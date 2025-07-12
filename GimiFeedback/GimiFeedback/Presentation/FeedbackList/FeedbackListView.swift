import SwiftUI

struct FeedbackListView: View {
    @StateObject var viewModel: FeedbackListViewModel
    
    init() {
        _viewModel = StateObject(wrappedValue: FeedbackListViewModel())
    }
    
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
    
    private var isLoading: Bool {
        !viewModel.isFeedbackChannelListLoading
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, alignment: .center, spacing: 32) {
                    ForEach(viewModel.feedbackChannelList) { item in
                        NavigationLink(destination: {
                            FeedbackChannelView(channelItem: item)
                        }) {
                            
                            VStack(alignment: .center) {
                                Image(systemName: "folder.fill")
                                    .resizable()
                                    .frame(width: 85, height: 67)
                                    .overlay(alignment: .topTrailing) {
                                        Circle()
                                            .fill(.red)
                                            .frame(width: 28, height: 28)
                                            .overlay {
                                                if let visibleFeedbackCount = viewModel.visibleFeedbackCount[item.id] {
                                                    Text("\(visibleFeedbackCount)")
                                                        .foregroundStyle(Color.white)
                                                }
                                            }
                                    }
                                
                                Text("title: \(item.channelTitle)")
                                
                                if let total = viewModel.feedbackCount[item.id] {
                                    Text("총 피드백 \(total)개")
                                }
                            }
                        }
                    }
                }
            }
            .padding(.top, 32)
            .navigationTitle("기미 피드백")
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    HStack {
                        Spacer()
                        
                        Text("\(viewModel.totalFeedbackCount)개")
                        
                        Spacer()
                        
                        Button(action: { }) {
                            Image(systemName: "folder.badge.plus")
                        }
                    }
                }
            }
            .toolbarBackground(Color.gray.opacity(0.1), for: .bottomBar)
            .toolbarBackground(.visible, for: .bottomBar)
            .onAppear {
                viewModel.send(.fetchFeedbackChannelList)
            }
        }
    }
}

#Preview {
    FeedbackListView()
}
