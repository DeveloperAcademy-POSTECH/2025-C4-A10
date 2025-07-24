//
//  LoginView.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/12/25.
//

import SwiftUI

struct InputNickNameView: View {
    
    @State var inputNickName: String = ""
    let scene: NickNameInputScene
    
    var onComplete: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("닉네임")
                .font(.title1)
            
            Text(scene.subTitle)
                .font(.footnote)
                .foregroundStyle(.gray400)
            
            TextField("", text: $inputNickName)
                .textFieldStyle(.gimiBase)
            
            Spacer()
            
            Button(scene.buttonText) {
                onComplete(inputNickName)
            }
            .buttonStyle(.gimiPrimary)
            .disabled(inputNickName.isEmpty)
        }
        .navigationBarBackButtonHidden()
        .padding()
        .padding(.top, 44)
    }
}

enum NickNameInputScene {
    case start
    case main
    
    var subTitle: String {
        switch self {
        case .start:
            "피드백을 요청할때 상대에게 보여질 닉네임이에요"
        case .main:
            "받는 사람에게 보일 닉네임이에요"
        }
    }
    
    var buttonText: String {
        switch self {
        case .start:
            "시작하기"
        case .main:
            "다음"
        }
    }
}

#Preview {
    let userViewModel = UserViewModel()
    
    InputNickNameView(scene: .main) { _ in }
        .environmentObject(userViewModel)
}
