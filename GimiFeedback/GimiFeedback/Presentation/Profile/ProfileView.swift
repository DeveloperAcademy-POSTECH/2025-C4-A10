//
//  ProfileView.swift
//  GimiFeedback
//
//  Created by 승찬 on 7/22/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: UserViewModel
    
    var body: some View {
        VStack {
            Button(action: {
                viewModel.send(.kakaoLogout)
            }) {
                Text("로그아웃")
            }
        }
    }
}
