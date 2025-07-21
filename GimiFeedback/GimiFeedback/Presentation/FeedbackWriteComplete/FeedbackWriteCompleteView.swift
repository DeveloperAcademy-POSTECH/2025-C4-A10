//
//  FeedbackWriteCompleteView.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/15/25.
//

import SwiftUI

struct FeedbackWriteCompleteView: View {
    @EnvironmentObject var mainRouter: MainNavigationRouter
    @EnvironmentObject var onboardingRouter: OnboardingNavigationRouter
    
    let isLoggedIn: Bool = FirebaseAuthManager.currentUser
    
    var body: some View {
        
        VStack {
            Text("피드백 작성이 완료되었어요")
            if isLoggedIn {
                Button(action: {
                    mainRouter.popToRootView()
                }) {
                    Text("홈으로 돌아가기")
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button(action: {
                    onboardingRouter.popToRootView()
                    onboardingRouter.push(to: .inputCode)
                }) {
                    Text("처음으로 돌아가기") // 코드 입력 뷰로 들어 가기
                }
                .buttonStyle(.borderedProminent)
                
                Button(action: {
                    onboardingRouter.popToRootView()
                }) {
                    Text("로그인 하고 피드백 받기")
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}

#Preview {
    FeedbackWriteCompleteView()
}
