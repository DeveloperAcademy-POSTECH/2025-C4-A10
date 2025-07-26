import SwiftUI

struct FeedbackDetailView: View {
    @StateObject var viewModel: FeedbackDetailViewModel
    @EnvironmentObject var router: MainNavigationRouter
    @State private var showDeleteAlert = false
    
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
        .gimiNavigationBar(
            trailingItems: {
                Button(action: {
                    showDeleteAlert = true
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.black)
                }
            }
        )
        .onChange(of: viewModel.isDeleted) { _, new in
            if new == true {
                router.pop()
            }
        }
        .onAppear {
            viewModel.send(.updateFeedbackVisibility)
        }
    }
}
