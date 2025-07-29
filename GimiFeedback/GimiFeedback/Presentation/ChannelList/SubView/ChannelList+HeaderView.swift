//
//  ChannelList+HeaderView.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/25/25.
//

import SwiftUI

extension ChannelListView {
    struct HeaderView: View {
        @ObservedObject var router: MainNavigationRouter
        @EnvironmentObject var userViewModel: UserViewModel
        
        var body: some View {
            HStack(spacing: 12) {
                Image(.gimme)
                    .resizable()
                    .frame(width: 115, height: 25)
                
                Spacer()
                
                Button(action: {
                    router.push(to: .inputCode)
                }) {
                    Text("피드백 주러가기")
                        .font(.title4)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.primaryLighten300)
                        .foregroundColor(.primaryBase)
                        .clipShape(Capsule())
                }
                
                Menu {
                    Button("닉네임 변경") {}
                    Button("로그아웃") { userViewModel.send(.kakaoLogout) }
                    Button("탈퇴하기", role: .destructive) {}
                } label: {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 34))
                        .foregroundColor(.primaryLighten300)
                }
            }
            .padding(.vertical, 16)
        }
    }
}

#Preview {
    ChannelListView.HeaderView(router: MainNavigationRouter())
}
