import SwiftUI

struct ChannelListView: View {
    @StateObject var viewModel: ChannelListViewModel
    @StateObject var router: MainNavigationRouter
    
    init() {
        _viewModel = StateObject(wrappedValue: ChannelListViewModel())
        _router = StateObject(wrappedValue: MainNavigationRouter())
    }
    
    private var isLoading: Bool {
        !viewModel.isChannelListLoading
    }
    
    var body: some View {
        NavigationStack(path: $router.destinations) {
            ContentView(viewModel: viewModel)
                .navigationDestination(
                    for: MainNavigationDestination.self
                ) { destination in
                    MainNavigationRoutingView(destination: destination)
                }
                .padding(.top, 32)
                .navigationTitle("기미 피드백")
                .toolbar {
                    ToolbarItemGroup(placement: .bottomBar) {
                        HStack {
                            Spacer()
                            
                            Text("\(viewModel.totalFeedbackCount)개")
                            
                            Spacer()
                            
                            Button(action: {
                                router.push(to: .feedbackChannelCreate)
                            }) {
                                Image(systemName: "folder.badge.plus")
                            }
                        }
                    }
                }
                .toolbarBackground(Color.gray.opacity(0.1), for: .bottomBar)
                .toolbarBackground(.visible, for: .bottomBar)
                .onAppear {
                    viewModel.send(.fetchChannelList)
                }
        }
        .environmentObject(router)
    }
}

extension ChannelListView {
    private struct ContentView: View {
        @EnvironmentObject var router: MainNavigationRouter
        @ObservedObject var viewModel: ChannelListViewModel
        
        let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
        
        var body: some View {
            ScrollView {
                LazyVGrid(columns: columns, alignment: .center, spacing: 32) {
                    ForEach(viewModel.channelList) { item in
                        Button {
                            router.push(to: .channelDetail(channelItem: item.channel))
                        } label: {
                            ChannelListItemView(item: item)
                        }
                    }
                }
            }
        }
    }
    
    private struct ChannelListItemView: View {
        let item: FeedbackChannelInfo
        
        var body: some View {
            VStack(alignment: .center) {
                Image(systemName: "folder.fill")
                    .resizable()
                    .frame(width: 85, height: 67)
                    .overlay(alignment: .topTrailing) {
                        Circle()
                            .fill(.red)
                            .frame(width: 28, height: 28)
                            .overlay {
                                Text("\(item.visibleFeedbackCount)")
                                    .foregroundStyle(Color.white)
                            }
                    }

                Text("title: \(item.channel.channelTitle)")
                Text("총 피드백 \(item.feedbackCount)개")
                    .foregroundStyle(Color.white)
            }
        }
    }
}
