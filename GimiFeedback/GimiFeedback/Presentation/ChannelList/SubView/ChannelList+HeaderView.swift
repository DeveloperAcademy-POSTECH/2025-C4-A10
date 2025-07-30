//
//  ChannelList+HeaderView.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/25/25.
//

import SwiftUI

extension ChannelListView {
    struct HeaderView: View {
        @EnvironmentObject var router: MainNavigationRouter
        @EnvironmentObject var userViewModel: UserViewModel
        @State private var logoutAlert: Bool = false
        @State private var deleteUserAlert: Bool = false
        
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
                    Button("닉네임 변경") { router.push(to: .updateNickName) }
                    Button("로그아웃") { logoutAlert = true }
                    Button("탈퇴하기", role: .destructive) { deleteUserAlert = true}
                } label: {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 34))
                        .foregroundColor(.primaryLighten300)
                }
            }
            .padding(.vertical, 16)
            .alert("로그아웃 하시겠습니까?", isPresented: $logoutAlert) {
                Button("취소", role: .cancel) {}
                Button("로그아웃", role: .destructive) {
                    userViewModel.send(.kakaoLogout)
                }
            } message: {
                Text("현재 계정에서 로그아웃됩니다.")
            }
            .alert("정말 탈퇴하시겠습니까?", isPresented: $deleteUserAlert) {
                Button("취소", role: .cancel) { }
                Button("탈퇴하기", role: .destructive) {
                    userViewModel.send(.deleteUser)
                }
            } message: {
                Text("탈퇴 시 계정 정보와 피드백이 모두 삭제됩니다.")
            }
        }
    }
}

#Preview {
    ChannelListView.HeaderView()
        .environmentObject(MainNavigationRouter())
}
