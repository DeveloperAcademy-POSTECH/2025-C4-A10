//
//  ChannelList+GuideToastView.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/30/25.
//

import SwiftUI

extension ChannelListView {
    struct GuideToastView: View {
        @ObservedObject var viewModel: ChannelListViewModel
        
        var body: some View {
            HStack {
                Spacer()
                SpeechBubbleView(message: "여기서 채널을 생성할 수 있어요")
            }
            .padding(.horizontal, -14)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation(.easeOut(duration: 0.4)) {
                        viewModel.send(.channelGuideUpdate)
                    }
                }
            }
        }
    }
}
