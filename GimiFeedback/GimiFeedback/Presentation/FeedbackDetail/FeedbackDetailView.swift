import SwiftUI

struct FeedbackDetailView: View {
    @StateObject var viewModel: FeedbackDetailViewModel
    @EnvironmentObject var router: MainNavigationRouter
    @State private var showDeleteAlert = false
    
    init(feedbackItem: Feedback) {
        _viewModel = StateObject(wrappedValue: .init(feedbackItem: feedbackItem))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("\(viewModel.feedbackItem.date.formattedDate)")
            
            VStack(spacing: 8) {
                FeedbackSectionView(
                    type: .keep,
                    details: $viewModel.keepFeedback,
                    onReveal: { detail in
                        viewModel.send(.visualizeDetail(detail: detail))
                    }
                )
                FeedbackSectionView(
                    type: .problem,
                    details: $viewModel.problemFeedback,
                    onReveal: { detail in
                        viewModel.send(.visualizeDetail(detail: detail))
                    }
                )
                FeedbackSectionView(
                    type: .try,
                    details: $viewModel.tryFeedback,
                    onReveal: { detail in
                        viewModel.send(.visualizeDetail(detail: detail))
                    }
                )
                FeedbackSectionView(
                    type: .other,
                    details: $viewModel.tryFeedback,
                    onReveal: { detail in
                        viewModel.send(.visualizeDetail(detail: detail))
                    }
                )
            }
        }
        .alert("피드백 삭제하기", isPresented: $showDeleteAlert) {
            Button("취소", role: .cancel) {}
            Button("확인", role: .destructive) {
                viewModel.send(.deleteFeedback)
            }
        } message: {
            Text("정말 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.")
        }
        .navigationTitle("\(viewModel.feedbackItem.writePerson)의 피드백")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    showDeleteAlert = true
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.black)
                }
            }
        }
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
