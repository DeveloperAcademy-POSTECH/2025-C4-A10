//
//  ChannelDetail+FeedbackListView.swift
//  GimiFeedback
//
//  Created by 승찬 on 7/23/25.
//

import SwiftUI

extension ChannelDetailView {
    struct FeedbackListView: View {
        let feedbackList: [Feedback]
        let onTapFeedbackItem: (Feedback) -> Void
        
        var body: some View {
            VStack(alignment: .leading, spacing: .zero) {
                Text("받은 피드백")
                    .font(.headline)
                    .foregroundStyle(.black)
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                    .padding(.horizontal, 20)
                
                ForEach(feedbackList.sorted(by: { $0.date > $1.date })) { item in
                    FeedbackRowView(
                        item: item,
                        onTapAction: {
                            onTapFeedbackItem(item)
                        }
                    )
                }
            }
        }
    }
}
