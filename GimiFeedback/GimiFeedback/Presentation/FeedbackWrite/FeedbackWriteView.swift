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
        onComplete: @escaping () -> Void
    ) {
        _viewModel = StateObject(
            wrappedValue: .init(feedbackChannel: feedbackChannel)
        )
        self.onComplete = onComplete
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 40) {
                VStack {
                    Text(viewModel.feedbackChannel.channelTitle)
                    Text(viewModel.feedbackChannel.content)
                }
                
                Rectangle()
                    .fill(Color.gray)
                    .frame(height: 8)
                    .frame(maxWidth: .infinity)
                    .padding(-20)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("닉네임")
                    Text("받는 사람에게 보여지는 닉네임입니다.")
                    TextField("", text: $viewModel.nickName)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(5)
                }
                
                FeedbackContentView(content: $viewModel.keeps, contentType: .keep)
                FeedbackContentView(content: $viewModel.problems, contentType: .problem)
                FeedbackContentView(content: $viewModel.trys, contentType: .try)
                FeedbackContentView(content: $viewModel.others, contentType: .other)
                
                Button(action: {
                    isShowCreateAlert = true
                }, label: {
                    Text("완료하기")
                        .font(Font.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 64)
                        .background(!viewModel.canCreate ? Color.black : Color.gray.opacity(0.5))
                        .cornerRadius(16)
                })
                .disabled(!viewModel.canCreate)
            }
        }
        .contentMargins(.horizontal, 20, for: .scrollContent)
        .navigationTitle("피드백 작성하기")
        .navigationBarTitleDisplayMode(.inline)
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
    }
}

extension FeedbackWriteView {
    struct FeedbackContentView: View {
        @Binding var content: [String]
        
        var contentType: FeedbackContentType
        
        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                Text(contentType.title)
                Text(contentType.content)
                ForEach(content.indices, id: \.self) { index in
                    TextEditor(text: $content[index])
                        .scrollContentBackground(.hidden)
                        .frame(height: 102)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(5)
                }
                
                if content.count < 3 {
                    Button {
                        content.append("")
                    } label: {
                        Text("+ 항목 추가하기")
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .foregroundColor(.black)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(12)
                    }
                    .padding(.top, 8)
                }
            }
        }
    }
}

#Preview {
    let feedbackChannel = FeedbackChannel(
        userID: "Test",
        channelTitle: "Test용 피드백입니다.",
        content: "Test용 내용입니다"
    )
    
    FeedbackWriteView(feedbackChannel: feedbackChannel) {
        print("Test")
    }
}
