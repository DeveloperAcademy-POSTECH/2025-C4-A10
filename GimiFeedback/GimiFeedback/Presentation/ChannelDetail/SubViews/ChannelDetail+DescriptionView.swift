//
//  ChannelDetail+DescriptionView.swift
//  GimiFeedback
//
//  Created by 승찬 on 7/23/25.
//

import SwiftUI

extension ChannelDetailView {
    struct DescriptionView: View {
        let channelItem: FeedbackChannel
        let onTapEdit: () -> Void
        
        var body: some View {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    
                    Text("내가 작성한 설명")
                        .font(.footnote)
                        .foregroundStyle(.gray400)
                    Spacer()
                    
                    Button(action: {
                        onTapEdit()
                    }) {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 20))
                            .foregroundStyle(.black)
                    }
                }
                
                Text(channelItem.content.isEmpty ? "자유롭게 피드백을 남겨주세요" : channelItem.content)
                    .font(.callout2)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            
            Rectangle()
                .foregroundStyle(.gray50)
                .frame(height: 8)
                .frame(maxWidth: .infinity)
        }
    }
}
