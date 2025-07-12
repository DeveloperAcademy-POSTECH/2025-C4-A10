//
//  OnboardingStartView.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/8/25.
//

import SwiftUI

struct OnboardingStartView: View {
    var body: some View {
        Text("솔직한 피드백, 더 나은 나를 위한 성장")
        Text("얼마나 매운 맛일지 미리 맛봐드릴게요. 상처는 적게, 성장은 크게.")
        
        Button {
            // TODO: 코드 입력 뷰 전환
        } label: {
            Text("코드 입력하기")
        }
        
        Button {
            // TODO: 로그인 뷰 전환
        } label: {
            Text("로그인")
        }
    }
}

#Preview {
    OnboardingStartView()
}
