//
//  ChannelCreateCompleteView.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/14/25.
//

import SwiftUI

struct ChannelCreateCompleteView: View {
    @EnvironmentObject var router: MainNavigationRouter
    
    @StateObject private var viewModel: ChannelCreateCompleteViewModel
    
    init(channelId: String, onClose: @escaping () -> Void = {}) {
        _viewModel = StateObject(
            wrappedValue: .init(channelId: channelId)
        )
        self.onClose = onClose
    }
    
    var onClose: () -> Void = {}
    
    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            
            ContentView()
            
            ShareView(channelId: viewModel.channelId, viewModel: viewModel)
            
            Spacer()
            
            Button("홈으로 돌아가기") {
                router.popToRootView()
            }
            .buttonStyle(.gimiPrimary)
        }
        .customPadding()
        .navigationBarBackButtonHidden()
        .overlay(alignment: .bottom) {
            if viewModel.showToast {
                ToastView(style: .basic(message: "코드가 복사되었습니다."), isPresented: $viewModel.showToast)
                    .padding(.bottom, 81)
                    .transition(.move(edge: .bottom))
            }
        }
    }
}

#Preview {
    ChannelCreateCompleteView(channelId: "1234") { }
}
