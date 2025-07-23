//
//  StartView.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/8/25.
//

import SwiftUI

struct StartView: View {
    @StateObject var router: OnboardingNavigationRouter
    @StateObject private var deepLinkViewModel: DeepLinkViewModel
    
    init() {
        _router = StateObject(wrappedValue: .init())
        _deepLinkViewModel = StateObject(wrappedValue: .init())
    }
    
    var body: some View {
        NavigationStack(path: $router.destinations) {
            ContentView()
                .navigationDestination(
                    for: StartNavigationDestination.self
                ) { destination in
                    StartNavigationRoutingView(destination: destination)
                }
                .onOpenURL { url in
                    deepLinkViewModel.send(.handleDeepLink(url))
                }
                .onChange(of: deepLinkViewModel.channel) { _, newValue in
                    if let channel = newValue {
                        router.push(to: .feedbackWrite(channel: channel))
                        deepLinkViewModel.send(.resetChannel)
                    }
                }
        }
        .environmentObject(router)
    }
}

extension StartView {
    private struct ContentView: View {
        @EnvironmentObject var router: OnboardingNavigationRouter
        @EnvironmentObject var userViewModel: UserViewModel
        
        var body: some View {
            VStack(spacing: 47) {
                VStack(spacing: 17) {
                    Text("LogoType")
                        .font(.title1)
                    
                    Text("상처 없이 성장하기")
                        .font(.title1)
                }
                
                Button {
                    userViewModel.send(.kakaoLogin)
                } label: {
                    Image(.kakaoLogin)
                        .resizable()
                        .frame(width: 300, height: 45)
                }
                
                Button {
                    router.push(to: .inputCode)
                } label: {
                    Text("로그인하지 않고 피드백 주기")
                        .font(.footnote)
                        .foregroundColor(.gray600)
                        .underline()
                }
            }
        }
    }
}

#Preview {
    StartView()
}
