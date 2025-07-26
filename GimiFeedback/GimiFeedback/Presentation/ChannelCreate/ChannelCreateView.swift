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
        VStack {
            VStack(alignment: .leading) {
                TitleSectionView(title: $viewModel.title)
                
                DescriptionSectionView(description: $viewModel.description,)
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .gimiNavigationBar(title: "채널 생성하기")
        .alert("채널 생성하기", isPresented: $showCreateAlert) {
            Button("취소", role: .cancel) { }
            Button("확인") {
                viewModel.send(.createFeedbackChannel)
            }
        } message: {
            Text(viewModel.messageContent)
        }
        .safeAreaInset(edge: .bottom) {
            Button("완료하기") {
                showCreateAlert = true
            }
            .buttonStyle(.gimiPrimary)
            .disabled(viewModel.buttonDisabled)
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .onChange(of: viewModel.title) {
            viewModel.send(.verifyTitleEmpty)
        }
        .onChange(of: viewModel.description) {
            viewModel.send(.setMessageContent)
        }
        .onChange(of: viewModel.createdChannelID) { _, newValue in
            if let id = newValue {
                router.push(
                    to: .feedbackChannelCreateComplete(channelID: id)
                )
            }
        }
        .onAppear {
            viewModel.send(.setMessageContent)
            UIApplication.shared.hideKeyboard()
        }
    }
}

#Preview {
    ChannelCreateView()
}
