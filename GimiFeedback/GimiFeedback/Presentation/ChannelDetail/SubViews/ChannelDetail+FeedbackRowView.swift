//
//  ChannelDetail+FeedbackRowView.swift
//  GimiFeedback
//
//  Created by 승찬 on 7/23/25.
//

import SwiftUI

extension ChannelDetailView {
    struct FeedbackRowView: View {
        let item: Feedback
        let onTapAction: () -> Void
        
        var body: some View {
            LazyVStack(alignment: .leading, spacing: .zero) {
                Divider()
                    .foregroundStyle(.gray50)
                
                VStack(alignment: .leading, spacing: 7) {
                    Text(item.date.formattedDate)
                        .font(.caption2)
                        .foregroundStyle(.gray600)
                    
                    Text("\(item.writePerson)의 피드백")
                        .font(.headline)
                        .foregroundStyle(.black)
                    
                    if !item.contentCount.isEmpty {
                        Text(item.contentCount)
                            .font(.caption3)
                            .foregroundStyle(.gray600)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(item.visiable ? Color.white : Color("BrandGreen-100"))
                .onTapGesture {
                    onTapAction()
                }
            }
        }
    }
}
