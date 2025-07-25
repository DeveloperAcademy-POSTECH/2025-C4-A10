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
            HeaderView(code: $viewModel.code)
            
            if let errorMessage = viewModel.errorMessage {
                ErrorView(errorMessage: errorMessage)
            }
            
            Spacer()
            
            Button("다음") {
                viewModel.send(.verifyCode)
            }
            .buttonStyle(.gimiPrimary)
            .disabled(viewModel.code.isEmpty)
        }
        .customPadding()
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
        .onAppear { UIApplication.shared.hideKeyboard() }
    }
}

extension InputCodeView {
    
    struct HeaderView: View {
        @Binding var code: String
        
        var body: some View {
            Text("초대 코드")
                .font(.title1)
            
            TextField("받은 코드를 붙여 넣어주세요", text: $code)
                .textFieldStyle(.gimiBase)
        }
    }
    
    struct ErrorView: View {
        let errorMessage: String
        
        var body: some View {
            HStack(spacing: 4) {
                Image(systemName: "xmark.circle")
                Text(errorMessage)
            }
            .foregroundColor(.error)
            .padding(.top, 4)
        }
    }
}

#Preview {
    InputCodeView { feedbackChannel in
        print("Test - \(feedbackChannel)")
    }
}
