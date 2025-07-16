import SwiftUI

struct FeedbackDetailView: View {
    @StateObject var viewModel: FeedbackDetailViewModel
    
    init(feedbackItem: Feedback) {
        _viewModel = StateObject(wrappedValue: FeedbackDetailViewModel(feedback: feedbackItem))
    }
    
    var body: some View {
        Text("FeedbackDetailView")
    }
}
