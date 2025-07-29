//
//  ChannelListItemView.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/15/25.
//

import SwiftUI

extension ChannelListView {
    struct ListItemView: View {
        let item: FeedbackChannelInfo
        
        var body: some View {
            VStack(alignment: .center, spacing: 0) {
                Image(item.folderImageString)
                    .resizable()
                    .frame(width: 150, height: 150)
                
                Text("\(item.channel.channelTitle)")
                    .font(.headline)
                    .foregroundStyle(.black)
                Text("\(item.feedbackCount)개의 피드백")
                    .font(.caption)
                    .foregroundStyle(.gray400)
            }
        }
    }
}

#Preview {
    ChannelListView.ListItemView(
        item: FeedbackChannelInfo(
            channel: .init(userID: "test", userName: "test", channelTitle: "사이드 프로젝트", content: "test"),
            feedbackCount: 3,
            visiableFeedback: false
        )
    )
}
