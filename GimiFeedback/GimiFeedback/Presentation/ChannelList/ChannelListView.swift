import SwiftUI

struct ChannelListView: View {
    @StateObject var viewModel: ChannelListViewModel
    
    init() {
        _viewModel = StateObject(wrappedValue: ChannelListViewModel())
    }
    
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if viewModel.channelList.isEmpty {
                    VStack(alignment: .center, spacing: 8) {
                        Text("피드백을 받기 위해\n채널을 생성해보세요.")
                        
                        Button(action: { }) {
                            Text("채널 생성하기")
                        }
                    }
                } else {
                    LazyVGrid(columns: columns, alignment: .center, spacing: 32) {
                        ForEach(viewModel.channelList) { item in
                            NavigationLink(destination: {
                                ChannelDetailView(channelItem: item.channel)
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
                }
            }
            .padding(.top, 32)
            .navigationTitle("기미 피드백")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button(action: { }) {
                        Text("코드 입력")
                    }
                    
                    Button(action: { }) {
                        Image(systemName: "person.crop.circle")
                    }
                }
                
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
                viewModel.send(.fetchChannelList)
            }
        }
    }
}
