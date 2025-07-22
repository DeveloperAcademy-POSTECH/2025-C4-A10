import SwiftUI

struct ChannelDetailView: View {
    
    @StateObject var viewModel: ChannelDetailViewModel
    @EnvironmentObject var router: MainNavigationRouter
    @State private var isShowDeleteAlert: Bool = false
    
    init(channelItem: FeedbackChannel) {
        _viewModel = StateObject(wrappedValue: .init(channelItem: channelItem))
    }
    
    var body: some View {
        ScrollView {
            VStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("내가 작성한 설명")
                    
                    Text(viewModel.channelItem.content)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gray.opacity(0.1))
                .clipShape(.rect(cornerRadius: 20))
                .overlay(alignment: .topTrailing) {
                    Button(action: {
                        router.push(to: .channelEdit(channelItem: viewModel.channelItem))
                    }) {
                        Image(systemName: "square.and.pencil")
                    }
                    
                }
                .padding(.horizontal)
                
                Divider()
                
                if viewModel.feedbackList.isEmpty {
                    Text("등록된 피드백이 없습니다.")
                    
                    ShareLink(item: "gimifeedback://feedbackWrite/\(viewModel.channelItem.id)") {
                        Text("채널 공유하기")
                    }
                } else {
                    ForEach(viewModel.feedbackList.sorted(by: { $0.date > $1.date })) { item in
                        LazyVStack(alignment: .leading, spacing: 8) {
                            Button {
                                router.push(to: .feedbackDetail(feedback: item))
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(item.date.formattedDate)
                                    
                                    Text("\(item.writePerson)의 피드백")
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.gray.opacity(0.1))
                                .clipShape(.rect(cornerRadius: 20))
                                .padding(.horizontal)
                            }
                        }
                        
                    }
                    
                }
                
            }
            .padding(.top, 32)
        }
        .gimiNavigationBar(
            title: "\(viewModel.channelItem.channelTitle)",
            trailingItems: {
                ShareLink(item: "gimifeedback://feedbackWrite/\(viewModel.channelItem.id)") {
                    Image(systemName: "square.and.arrow.up")
                }
                
                Button(action: { isShowDeleteAlert = true }) {
                    Image(systemName: "trash")
                }
            })
        .alert("채널 삭제하기", isPresented: $isShowDeleteAlert) {
            
            Button(action: {
                isShowDeleteAlert = true
            }) {
                Text("취소")
            }
            
            Button(action: {
                viewModel.send(.deleteChannel)
                isShowDeleteAlert = false
                
            }) {
                Text("확인")
            }
            
        } message: {
            Text("정말 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.")
        }
        .onChange(of: viewModel.isDelete) { _, new in
            if new == true {
                router.pop()
            }
        }
        .onAppear {
            viewModel.send(.fetchFeedbackList)
        }
        .refreshable {
            viewModel.send(.getFeedbackChannelItem)
        }
        
    }
}
