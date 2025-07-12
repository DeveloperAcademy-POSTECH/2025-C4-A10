//
//  OnboardingStartView.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/8/25.
//

import SwiftUI

struct OnboardingStartView: View {
    @StateObject var router: NavigaitionRouter<NavigationOnboardingDestination>
    
    init() {
        _router = StateObject(wrappedValue: NavigaitionRouter<NavigationOnboardingDestination>())
    }
    
    var body: some View {
        NavigationStack(path: $router.destinations) {
            ContentView()
                .navigationDestination(for: NavigationOnboardingDestination.self) { destination in
                    switch destination {
                    case .inputCode:
                        InputCodeView()
                    case .login:
                        OnboardingLoginView()
                    case .feedbackWriteComplete:
                        // TODO: 피드백 완료 이동
                        FeedbackListView()
                    case .feedbackWrite(code: _):
                        // TODO: 피드백 생성 이동
                        FeedbackListView()
                    }
                }
        }
        .environmentObject(router)
        
    }
}

extension OnboardingStartView {
    private struct ContentView: View {
        @EnvironmentObject var router: NavigaitionRouter<NavigationOnboardingDestination>
        
        var body: some View {
            VStack {
                Text("솔직한 피드백, 더 나은 나를 위한 성장")
                Text("얼마나 매운 맛일지 미리 맛봐드릴게요. 상처는 적게, 성장은 크게.")
                
                Button {
                    router.push(to: .inputCode)
                } label: {
                    Text("코드 입력하기")
                }
                
                Button {
                    router.push(to: .login)
                } label: {
                    Text("로그인")
                }
            }
        }
    }
}

#Preview {
    OnboardingStartView()
}
