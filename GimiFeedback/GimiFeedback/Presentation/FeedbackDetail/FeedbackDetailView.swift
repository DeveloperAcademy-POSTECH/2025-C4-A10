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
                /// 디바이더 위 부분 까지
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(viewModel.feedbackItem.writePerson)의 피드백")
                        .font(.title1)
                        .foregroundStyle(.black)
                    
                    Text("\(viewModel.feedbackItem.date.formattedDate)")
                        .font(.caption2)
                        .foregroundStyle(.gray600)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                
                Rectangle()
                    .foregroundStyle(.gray50)
                    .frame(height: 8)
                    .frame(maxWidth: .infinity)
            
                /// 피드백 리스트
                VStack(spacing: 40) {
                    SectionView(
                        type: .typeContinue,
                        details: $viewModel.keepFeedback,
                        onReveal: { content in
                            viewModel.send(.visualizeDetail(detail: content))
                        })
                    
                    SectionView(
                        type: .typeStop,
                        details: $viewModel.problemFeedback,
                        onReveal: { content in
                            viewModel.send(.visualizeDetail(detail: content))
                        })
                    
                    SectionView(
                        type: .typeStart,
                        details: $viewModel.tryFeedback,
                        onReveal: { content in
                            viewModel.send(.visualizeDetail(detail: content))
                        })
                    
                    SectionView(
                        type: .other,
                        details: $viewModel.otherFeedback,
                        onReveal: { content in
                            viewModel.send(.visualizeDetail(detail: content))
                        })
                }
                .padding(.top, 20)
            }
        }
        .padding(.top, 20)
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
