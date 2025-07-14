//
//  OnboardingLoginView.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/12/25.
//

import SwiftUI

struct OnboardingLoginView: View {
    @EnvironmentObject var router: OnboardingNavigationRouter
    var body: some View {
        Text("솔직한 피드백, 더 나은 나를 위한 성장")
        
        Button {
            // TODO: 카카오 로그인 동작
        } label: {
            Text("카카오로 계속하기")
        }
        
        Button {
            router.push(to: .inputCode)
        } label: {
            Text("로그인하지 않고 피드백 주기")
        }
    }
}

#Preview {
    OnboardingLoginView()
}
