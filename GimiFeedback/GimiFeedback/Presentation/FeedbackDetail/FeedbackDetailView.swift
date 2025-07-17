import SwiftUI

struct FeedbackDetailView: View {
    @StateObject var viewModel: FeedbackDetailViewModel
    
    @State private var showDeleteAlert = false
    
    init(feedbackItem: Feedback) {
        _viewModel = StateObject(wrappedValue: FeedbackDetailViewModel(feedbackItem: feedbackItem))
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("\(viewModel.feedbackItem.date.formattedDate)")
                
                VStack(spacing: 8) {
                    FeedbackSectionView(
                        title: "Keep",
                        details: $viewModel.keepFeedback,
                        onReveal: { detail in
                            viewModel.send(.visualizeDetail(detail: detail))
                        }
                    )
                    FeedbackSectionView(
                        title: "Problem",
                        details: $viewModel.problemFeedback,
                        onReveal: { detail in
                            viewModel.send(.visualizeDetail(detail: detail))
                        }
                    )
                    FeedbackSectionView(
                        title: "try",
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
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        // TODO: 뒤로가기
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showDeleteAlert = true
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.black)
                    }
                }
            }
        }
    }
}
