//
//  ChannelListItemView.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/15/25.
//

import SwiftUI

extension ChannelListView {
    struct ChannelListItemView: View {
        let item: FeedbackChannelInfo
        
        var body: some View {
            VStack(alignment: .center) {
                Image(systemName: "folder.fill")
                    .resizable()
                    .frame(width: 85, height: 67)
                    .overlay(alignment: .topTrailing) {
                        Circle()
                            .fill(.red)
                            .frame(width: 28, height: 28)
                            .overlay {
                                Text("\(item.visibleFeedbackCount)")
                                    .foregroundStyle(Color.white)
                            }
                    }
                
                Text("title: \(item.channel.channelTitle)")
                Text("총 피드백 \(item.feedbackCount)개")
                    .foregroundStyle(Color.white)
            }
        }
    }
}
