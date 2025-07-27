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
            VStack(spacing: .zero) {
                /// 콘텐츠 설명
                DescriptionView(
                    channelItem: viewModel.channelItem,
                    onTapEdit: {
                        router.push(
                            to: .channelEdit(channelItem: viewModel.channelItem)
                        )
                    }
                )
                
                /// 피드백 없을 때 화면
                if viewModel.feedbackList.isEmpty {
                    EmptyFeedbackView(channelId: viewModel.channelItem.id)
                } else {
                    /// 피드백 있을 때 화면
                    FeedbackListView(
                        feedbackList: viewModel.feedbackList,
                        onTapFeedbackItem: { item in
                            router.push(to: .feedbackDetail(feedback: item))
                        }
                    )
                }
            }
        }
        .gimiNavigationBar(
            title: "\(viewModel.channelItem.channelTitle)",
            trailingItems: {
                ShareLink(item: "gimifeedback://feedbackWrite/\(viewModel.channelItem.id)") {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundStyle(.black)
                }
                Button(action: { isShowDeleteAlert = true }) {
                    Image(systemName: "trash")
                        .foregroundStyle(.black)
                }
            }
        )
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
