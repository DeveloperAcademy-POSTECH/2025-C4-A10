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
            VStack(alignment: .center) {
                Image(item.folderImageString)
                    .resizable()
                    .frame(width: 85, height: 67)
                
                Text("title: \(item.channel.channelTitle)")
                Text("총 피드백 \(item.feedbackCount)개")
                    .foregroundStyle(Color.white)
            }
        }
    }
}
