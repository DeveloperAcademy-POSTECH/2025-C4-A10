//
//  ChannelCreateComplete+ShareView.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/30/25.
//

import SwiftUI

extension ChannelCreateCompleteView {
    struct ShareView: View {
        let channelId: String
        @ObservedObject var viewModel: ChannelCreateCompleteViewModel
        
        var body: some View {
            VStack(spacing: 12) {
                CodeShareView(channelId: channelId, viewModel: viewModel)
                InviteShareView(channelId: channelId, viewModel: viewModel)
            }
        }
    }
    
    struct CodeShareView: View {
        let channelId: String
        @ObservedObject var viewModel: ChannelCreateCompleteViewModel
        
        var body: some View {
            HStack {
                Text(channelId)
                    .font(.footnote)
                    .foregroundColor(.gray600)
                    .lineLimit(1)
                    .truncationMode(.middle)
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        viewModel.showToast = true
                    }
                    UIPasteboard.general.string = channelId
                }) {
                    Image(systemName: "document.on.document")
                        .foregroundColor(.gray600)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(.gray50)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(.gray100, lineWidth: 1)
            )
        }
    }
    
    struct InviteShareView: View {
        let channelId: String
        @ObservedObject var viewModel: ChannelCreateCompleteViewModel
        
        var body: some View {
            HStack(spacing: 12) {
                Button(action: {
                    viewModel.send(.shareToKakao(channelId))
                }, label: {
                    Text("카카오로 초대장 보내기")
                        .font(.callout2)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(.kakao)
                        .cornerRadius(10)
                })
                .layoutPriority(1)
                
                ShareLink(item: "gimifeedback://feedbackWrite/\(channelId)") {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(.black)
                        .frame(width: 48, height: 48)
                        .background(.gray100)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    ChannelCreateCompleteView.ShareView(
        channelId: "test",
        viewModel: ChannelCreateCompleteViewModel(
            channelId: "test"
        )
    )
}
