//
//  FeedbackWriteView.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/15/25.
//

import SwiftUI

struct FeedbackWriteView: View {
    @StateObject var viewModel: FeedbackWriteViewModel
    @State private var isShowCreateAlert: Bool = false
    var onComplete: () -> Void
    
    init(
        feedbackChannel: FeedbackChannel,
        inputNickName: String,
        onComplete: @escaping () -> Void
    ) {
        _viewModel = StateObject(
            wrappedValue: .init(
                feedbackChannel: feedbackChannel,
                nickName: inputNickName
            )
        )
        self.onComplete = onComplete
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HeaderView(userName: viewModel.feedbackChannel.userName)
                
                WriteContentView(feedbackChannel: viewModel.feedbackChannel)

                SplitView()
                    .padding(.horizontal, -20)
                
                WriteView(content: $viewModel.continues, contentType: .typeContinue)
                WriteView(content: $viewModel.stops, contentType: .typeStop)
                
                Button("완료하기") {
                    isShowCreateAlert = true
                }
                .buttonStyle(.gimiPrimary)
                .disabled(!viewModel.canCreate)
            }
        }
        .gimiNavigationBar(title: "피드백 작성하기")
        .contentMargins(.horizontal, 20, for: .scrollContent)
        .padding(.top, 24)
        .alert("작성 완료하기", isPresented: $isShowCreateAlert) {
            Button("취소", role: .cancel) { }
            Button("확인") {
                viewModel.send(.feedbackWrite)
            }
        } message: {
            Text("이대로 피드백을 전송하시겠습니까?\n이 작업은 취소할 수 없습니다.")
        }
        .onChange(of: viewModel.createdFeedback) { _, newValue in
            if newValue != nil {
                onComplete()
            }
        }
        .onAppear { UIApplication.shared.hideKeyboard() }
    }
}

#Preview {
    let feedbackChannel = FeedbackChannel(
        userID: "Test",
        userName: "Test",
        channelTitle: "Test용 피드백입니다.",
        content: "Test용 내용입니다"
    )
    
    FeedbackWriteView(feedbackChannel: feedbackChannel, inputNickName: "test") {
        print("Test")
    }
}
