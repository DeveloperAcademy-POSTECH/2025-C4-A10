//
//  ChannelList+ListEmptyView.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/30/25.
//

import SwiftUI

extension ChannelListView {
    struct ListEmptyView: View {
        var body: some View {
            VStack {
                Text("피드백 주고 싶은 주제로 채널을 만들어보세요!\n채널을 공유하고 피드백을 받아볼 수 있어요.")
                    .font(.callout2)
                    .foregroundStyle(.primaryDarken200)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
            }
        }
    }
}

#Preview {
    ChannelListView.ListEmptyView()
}
