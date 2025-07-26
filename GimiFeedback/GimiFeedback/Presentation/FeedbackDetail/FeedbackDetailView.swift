import SwiftUI

struct FeedbackDetailView: View {
    @StateObject var viewModel: FeedbackDetailViewModel
    @EnvironmentObject var router: MainNavigationRouter
    @State private var isShowDeleteAlert = false
    @State private var isShowToast = false
    
    init(feedbackItem: Feedback) {
        _viewModel = StateObject(wrappedValue: .init(feedbackItem: feedbackItem))
    }
    
    var body: some View {
        ScrollView {
            /// 전체
            VStack(alignment: .leading, spacing: .zero) {
                DescriptionView(
                    writePerson: viewModel.feedbackItem.writePerson,
                    date: viewModel.feedbackItem.date.formattedDate
                )
                
                /// 피드백 리스트
                VStack(spacing: 40) {
                    SectionView(
                        type: .typeContinue,
                        details: $viewModel.continueFeedbackList,
                        onReveal: { content in
                            viewModel.send(.visualizeDetail(detail: content))
                        })
                    
                    SectionView(
                        type: .typeStop,
                        details: $viewModel.stopFeedbackList,
                        onReveal: { content in
                            viewModel.send(.visualizeDetail(detail: content))
                        })
                }
                .padding(.top, 20)
            }
        }
        .overlay(alignment: .center) {
            if viewModel.isShowToast {
                ToastView(style: .guide, isPresented: $viewModel.isShowToast)
            }
        }
        .gimiNavigationBar(
            trailingItems: {
                Button(action: {
                    isShowDeleteAlert = true
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.black)
                }
            }
        )
        .alert("피드백 삭제하기", isPresented: $isShowDeleteAlert) {
            Button("취소", role: .cancel, action: { })
            Button("확인", role: .destructive, action: { viewModel.send(.deleteFeedback) })
        } message: {
            Text("정말 삭제하시겠습니까?\n이 작업은 되둘릴 수 없습니다.")
        }
        .onChange(of: viewModel.isDeleted) { _, new in
            if new == true {
                router.pop()
            }
        }
        .onAppear {
            viewModel.send(.updateFeedbackVisibility)
            viewModel.send(.updateToast)
        }
    }
}
