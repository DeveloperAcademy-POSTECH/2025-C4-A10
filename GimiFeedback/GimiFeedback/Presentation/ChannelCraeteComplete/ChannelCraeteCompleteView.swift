//
//  ChannelCreateCompleteView.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/14/25.
//

import SwiftUI

struct ChannelCreateCompleteView: View {
    let channelID: String
    var onClose: () -> Void = {}

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "checkmark")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.black)

            VStack(spacing: 16) {
                Text("피드백 채널이 생성되었어요")
                    .font(Font.system(size: 20, weight: .bold))
                    .multilineTextAlignment(.center)

                Text("아래 링크를 복사하거나 공유하여\n피드백을 요청하세요")
                    .font(Font.system(size: 16, weight: .medium))
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 16) {
                Text(channelID)
                    .font(Font.system(size: 12, weight: .regular))
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: 44)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(5)
                    .padding(.horizontal)

                HStack(spacing: 8) {
                    Button(action: {
                        // TODO: 카카오 공유
                    }, label: {
                        Text("카카오로 초대장 보내기")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.yellow)
                            .foregroundColor(.black)
                            .cornerRadius(10)
                    })
                    
                    // TODO: 임시 데이터
                    if let url = URL(string: "https://gimifeedback.com/\(channelID)") {
                        ShareLink(item: url) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.title2)
                                .padding()
                                .background(Color(UIColor.systemGray5))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
                .padding(.horizontal)
            }

            Spacer()
        }
    }
}

#Preview {
    ChannelCreateCompleteView(channelID: "1234") { }
}
