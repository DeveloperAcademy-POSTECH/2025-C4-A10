//
//  LoginView.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/12/25.
//

import SwiftUI

struct InputNickNameView: View {
    
    @State var inputNickName: String = ""
    let mode: NickNameInputMode
    
    var onComplete: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("닉네임")
                .font(.title1)
            
            Text(mode.subTitle)
                .font(.footnote)
                .foregroundStyle(.gray400)
            
            TextField("", text: $inputNickName)
                .textFieldStyle(.gimiBase)
            
            Spacer()
            
            Button(mode.buttonText) {
                onComplete(inputNickName)
            }
            .buttonStyle(.gimiPrimary)
            .disabled(inputNickName.isEmpty)
        }
        .customPadding()
        .navigationBarBackButtonHidden(mode == .startUserInput)
        .padding(.top, mode == .startUserInput ? 44 : 0)
        .onAppear { UIApplication.shared.hideKeyboard() }
    }
}

enum NickNameInputMode {
    case startUserInput
    case feedbackWriteInput
    
    var subTitle: String {
        switch self {
        case .startUserInput:
            "피드백을 요청할때 상대에게 보여질 닉네임이에요"
        case .feedbackWriteInput:
            "받는 사람에게 보일 닉네임이에요"
        }
    }
    
    var buttonText: String {
        switch self {
        case .startUserInput:
            "시작하기"
        case .feedbackWriteInput:
            "다음"
        }
    }
}

#Preview {
    let userViewModel = UserViewModel()
    
    InputNickNameView(mode: .feedbackWriteInput) { _ in }
        .environmentObject(userViewModel)
}
