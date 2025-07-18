//
//  InputCodeView.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/12/25.
//

import SwiftUI

struct InputCodeView: View {
    @StateObject var viewModel: InputCodeViewModel
    var onComplete: (FeedbackChannel) -> Void
    
    init(onComplete: @escaping (FeedbackChannel) -> Void) {
        _viewModel = StateObject(wrappedValue: .init())
        self.onComplete = onComplete
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("코드 입력하기")
            
            TextField("받은 코드를 붙여 넣어주세요", text: $viewModel.code)
                .padding(.vertical, 8)
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray),
                    alignment: .bottom
                )
            
            if let errorMessage = viewModel.errorMessage {
                HStack(spacing: 4) {
                    Image(systemName: "xmark.circle")
                    Text(errorMessage)
                }
                .foregroundColor(.red)
                .padding(.top, 4)
            }
            
            Spacer()
            
            Button(action: {
                viewModel.send(.verifyCode)
            }, label: {
                Text("완료하기")
                    .font(Font.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: 66)
                    .background(Color.black)
                    .cornerRadius(20)
            })
            .disabled(viewModel.code.isEmpty)
        }
        .padding()
        .onChange(of: viewModel.feedbackChannel) { _, newValue in
            if let feedbackChannel = newValue {
                onComplete(feedbackChannel)
            }
        }
        .onChange(of: viewModel.errorMessage) { _, newValue in
            if newValue != nil {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
            }
        }
    }
}

#Preview {
    InputCodeView { feedbackChannel in
        print("Test - \(feedbackChannel)")
    }
}
