//
//  LoginView.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/12/25.
//

import SwiftUI

struct NickNameInputView: View {
    @EnvironmentObject var router: OnboardingNavigationRouter
    @EnvironmentObject var viewModel: UserViewModel
    
    var body: some View {
        Text("닉네임")
            .font(.title1)
        
        Text("피드백을 요청할 때 상대에게 보여질 닉네임이에요")
            .font(.footnote)
            .foregroundStyle(.gray600)

        TextField("hello", text: $viewModel.nickName)
            .textFieldStyle(.gimiBase)
        
        Button("시작하기") {
            
        }
        .buttonStyle(.gimiPrimary)
    }
}

#Preview {
    NickNameInputView()
}
