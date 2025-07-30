import SwiftUI

struct ChannelDetailView: View {
    
    @StateObject var viewModel: ChannelDetailViewModel
    @EnvironmentObject var router: MainNavigationRouter
    @State private var isShowDeleteAlert: Bool = false
    @State private var isShowSheet: Bool = false
    @State private var isShowActivity: Bool = false
    @State private var isShowToast: Bool = false
    
    init(channelItem: FeedbackChannel) {
        _viewModel = StateObject(wrappedValue: .init(channelItem: channelItem))
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: .zero) {
                    /// 콘텐츠 설명 (항상 노출)
                    DescriptionView(
                        channelItem: viewModel.channelItem,
                        onTapEdit: {
                            router.push(
                                to: .channelEdit(channelItem: viewModel.channelItem)
                            )
                        }
                    )
                    
                    /// 피드백 영역만 로딩 분기
                    if !viewModel.isLoading {
                        switch viewModel.feedbackList.isEmpty {
                        case true:
                            EmptyFeedbackView(
                                channelId: viewModel.channelItem.id,
                                tapAction: { isShowSheet = true }
                            )
                        case false:
                            FeedbackListView(
                                feedbackList: viewModel.feedbackList,
                                onTapFeedbackItem: { item in
                                    router.push(to: .feedbackDetail(feedback: item))
                                }
                            )
                        }
                    }
                }
            }
        }
        .overlay(alignment: .center) {
            if viewModel.isLoading {
                LoadingView(text: "로딩 중 입니다.")
            }
        }
        .gimiNavigationBar(
            title: "\(viewModel.channelItem.channelTitle)",
            trailingItems: {
                Button(action: { isShowSheet = true }) {
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
        .sheet(isPresented: $isShowSheet) {
            ShareSheetView(
                isSheet: $isShowSheet,
                isShowToast: $isShowToast,
                isShowActivity: $isShowActivity,
                channelId: viewModel.channelItem.id.uuidString,
                shareToKakaoAction: {
                    viewModel.send(.shareToKakao(viewModel.channelItem.id.uuidString))
                })
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
            viewModel.send(.fetchFeedbackList)
        }
    }
}
