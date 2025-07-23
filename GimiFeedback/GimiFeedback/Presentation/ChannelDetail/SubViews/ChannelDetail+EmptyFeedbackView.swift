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

        var body: some View {
            VStack(alignment: .center, spacing: 20) {
                Spacer()
                
                Text("아직 받은 피드백이 없어요.\n 첫 번째 피드백을 요청해보세요.")
                    .font(.callout)
                    .fontWeight(.bold)
                    .foregroundStyle(.primaryDarken100)
                    .multilineTextAlignment(.center)
                
                // TODO: 공유하기를 누를때 어떻게 할건지 (카카오톡과 일반 ShareLink 방법 중 논의)
//                Button(action: { }) {
//                    Text("채널 공유하기")
//                        .font(.callout2)
//                        .foregroundStyle(.primaryDarken100)
//                        .frame(width: 123, height: 47)
//                        .background(.primaryLighten300)
//                        .clipShape(.rect(cornerRadius: 12))
//                }
//                
                ShareLink(item: "gimifeedback://feedbackWrite/\(channelId)") {
                    Text("채널 공유하기")
                        .font(.callout2)
                        .foregroundStyle(.primaryDarken100)
                        .frame(width: 123, height: 47)
                        .background(.primaryLighten300)
                        .clipShape(.rect(cornerRadius: 12))
                }
                
                Spacer()
            }
        }
    }
}
