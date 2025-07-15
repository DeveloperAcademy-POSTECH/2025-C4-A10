//
//  FeedbackListView.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/8/25.
//

import SwiftUI

struct FeedbackListView: View {
    @StateObject var viewModel: FeedbackListViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    
    init() {
        _viewModel = StateObject(wrappedValue: FeedbackListViewModel())
    }
    
    var body: some View {
        Button {
            userViewModel.send(.kakaoLogout)
        } label: {
            Text("로그아웃")
        }
    }
}

#Preview {
    FeedbackListView()
}
