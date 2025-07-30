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
    @EnvironmentObject private var userViewModel: UserViewModel
    
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
                        router.push(to: .feedbackWriteInputNickName(channel: channel))
                        deepLinkViewModel.send(.resetChannel)
                    }
                }
                .onAppear {
                    if userViewModel.isLoggedIn {
                        router.push(to: .startUserinputNickName)
                    }
                }
                .onChange(of: userViewModel.isLoggedIn) { _, newValue in
                    if newValue {
                        router.push(to: .startUserinputNickName)
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
            VStack(alignment: .center, spacing: 13) {
                Spacer()
                
                Image(.gimme)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(.primaryBase)
                    .frame(width: 160, height: 35)
                
                Text("상처 없이 성장하기")
                    .font(.title2)
                    .foregroundColor(.primaryBase)
                    .padding(.bottom, 244)
                
                Button {
                    userViewModel.send(.kakaoLogin)
                } label: {
                    Image(.kakaoLogin)
                        .resizable()
                        .frame(width: 300, height: 45)
                }
                .padding(.bottom, 11)
                
                Button {
                    router.push(to: .inputCode)
                } label: {
                    Text("로그인하지 않고 피드백 주기")
                        .font(.footnote)
                        .foregroundColor(.gray600)
                        .underline()
                }
                .padding(.bottom, 80)
            }
        }
    }
}

#Preview {
    StartView()
        .environmentObject(UserViewModel())
}
