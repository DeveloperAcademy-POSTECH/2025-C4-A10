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
        Group {
            switch viewModel.status {
            case .writing:
                contentView
            case .loading:
                LoadingView(text: "피드백을 전송중이에요...")
                    .navigationBarBackButtonHidden()
            case .success:
                Color.clear
                    .onAppear {
                        onComplete()
                    }
            }
        }
        .alert(isPresented: .constant(viewModel.errorMessage != nil)) {
            Alert(
                title: Text("피드백 전송 실패"),
                message: Text(viewModel.errorMessage ?? "알 수 없는 오류가 발생했어요."),
                dismissButton: .default(Text("확인")) {
                    viewModel.send(.clearError)
                }
            )
        }
    }

    private var contentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HeaderView(userName: viewModel.feedbackChannel.userName)
                    .padding(.bottom, -2)

                WriteContentView(feedbackChannel: viewModel.feedbackChannel)

                SplitView()
                    .padding(.horizontal, -20)

                WriteView(content: $viewModel.continues, contentType: .typeContinue)
                    .padding(.bottom, 20)
                WriteView(content: $viewModel.stops, contentType: .typeStop)
                    .padding(.bottom, 60)

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
        print("Test 완료")
    }
}
