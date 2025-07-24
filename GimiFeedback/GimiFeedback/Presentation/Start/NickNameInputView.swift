//
//  LoginView.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/12/25.
//

import SwiftUI

struct NickNameInputView: View {
    @EnvironmentObject var viewModel: UserViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("닉네임")
                .font(.title1)
            
            Text("피드백을 요청할 때 상대에게 보여질 닉네임이에요")
                .font(.footnote)
                .foregroundStyle(.gray400)
            
            TextField("", text: $viewModel.inputNickName)
                .textFieldStyle(.gimiBase)
            
            Spacer()
            
            Button("시작하기") {
                viewModel.send(.nickNameSave)
            }
            .buttonStyle(.gimiPrimary)
            .disabled(viewModel.inputNickName.isEmpty)
        }
        .navigationBarBackButtonHidden()
        .padding()
        .padding(.top, 44)
    }
}

#Preview {
    let userViewModel = UserViewModel()
    
    NickNameInputView()
        .environmentObject(userViewModel)
}
