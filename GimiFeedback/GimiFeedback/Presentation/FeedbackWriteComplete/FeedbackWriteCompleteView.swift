//
//  FeedbackWriteCompleteView.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/15/25.
//

import SwiftUI

struct FeedbackWriteCompleteView: View {
    let action: () -> Void
    let isLoggedIn: Bool = FirebaseAuthManager.currentUser
    
    var buttonText: String {
        isLoggedIn ? "홈으로 돌아가기": "처음으로 돌아가기"
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 16) {
                Image(systemName: "checkmark")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.black)

                Text("피드백 전송이 완료되었어요")
                    .font(.title1)
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity)
            
            Spacer()
            
            Button(buttonText) {
                action()
            }
            .buttonStyle(.gimiPrimary)
        }
        .customPadding()
        .ignoresSafeArea(edges: .top)
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    FeedbackWriteCompleteView {
        print("Test")
    }
}
