//
//  ChannelDetail+EmptyFeedbackView.swift
//  GimiFeedback
//
//  Created by 승찬 on 7/23/25.
//

import SwiftUI

extension ChannelDetailView {
    struct EmptyFeedbackView: View {
        let channelId: UUID
        let tapAction: () -> Void

        var body: some View {
            VStack(alignment: .center, spacing: 20) {
                Spacer()
                    .frame(minHeight: 210)
                
                Text("아직 받은 피드백이 없어요.\n 첫 번째 피드백을 요청해보세요.")
                    .font(.callout)
                    .fontWeight(.bold)
                    .foregroundStyle(.primaryDarken100)
                    .multilineTextAlignment(.center)
                
                Button(action: { tapAction() }) {
                    Text("채널 공유하기")
                        .font(.callout2)
                        .foregroundStyle(.primaryDarken100)
                        .frame(width: 123, height: 47)
                        .background(.primaryLighten300)
                        .clipShape(.rect(cornerRadius: 12))
                }
            }
        }
    }
}
