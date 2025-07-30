//
//  ChannelCreateView.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/14/25.
//

import SwiftUI

struct ChannelCreateView: View {
    @StateObject var viewModel: ChannelCreateViewModel
    @EnvironmentObject var router: MainNavigationRouter
    
    @State private var showCreateAlert: Bool = false
    
    init() {
        _viewModel = StateObject(wrappedValue: .init())
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            TitleView(title: $viewModel.title)
            
            DescriptionView(description: $viewModel.description)
            
            Spacer()
            
            Button("완료하기") {
                showCreateAlert = true
            }
            .buttonStyle(.gimiPrimary)
            .disabled(viewModel.buttonDisabled)
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 20)
        .gimiNavigationBar(title: "채널 생성하기")
        .alert("채널 생성하기", isPresented: $showCreateAlert) {
            Button("취소", role: .cancel) { }
            Button("확인") {
                viewModel.send(.createFeedbackChannel)
            }
        } message: {
            Text(viewModel.messageContent)
        }
        .onChange(of: viewModel.createdChannelID) { _, newValue in
            if let id = newValue {
                router.push(
                    to: .feedbackChannelCreateComplete(channelID: id)
                )
            }
        }
        .onAppear { UIApplication.shared.hideKeyboard() }
    }
}

#Preview {
    ChannelCreateView()
}
