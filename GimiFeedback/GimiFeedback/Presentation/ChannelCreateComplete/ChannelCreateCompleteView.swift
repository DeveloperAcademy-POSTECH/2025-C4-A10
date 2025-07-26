//
//  ChannelCreateCompleteView.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/14/25.
//

import SwiftUI

struct ChannelCreateCompleteView: View {
    @EnvironmentObject var router: MainNavigationRouter
    
    @StateObject private var viewModel: ChannelCreateCompleteViewModel
    
    init(channelID: String, onClose: @escaping () -> Void = {}) {
        _viewModel = StateObject(wrappedValue: .init())
        self.channelID = channelID
        self.onClose = onClose
    }
    
    let channelID: String
    var onClose: () -> Void = {}
    
    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            
            VStack(alignment: .center, spacing: 16) {
                Image(systemName: "checkmark")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundColor(.black)
                
                VStack(spacing: 12) {
                    Text("피드백 채널이 생성되었어요")
                        .font(.title1)
                    
                    Text("아래 링크를 복사하거나 공유하여\n피드백을 요청하세요")
                        .font(.callout)
                        .multilineTextAlignment(.center)
                }
            }
            
            VStack(spacing: 12) {
                HStack {
                    Text(channelID)
                        .font(Font.system(size: 12, weight: .regular))
                        .lineLimit(1)
                        .truncationMode(.middle)
                    
                    Spacer()
                    
                    Button(action: {
                        UIPasteboard.general.string = channelID
                    }) {
                        Image(systemName: "document.on.document")
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: 44)
                .background(Color(UIColor.systemGray6))
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(
                            .gray100,
                            lineWidth: 1
                        )
                )
                
                HStack(spacing: 12) {
                    Button(action: {
                        viewModel.send(.shareToKakao(channelID))
                    }, label: {
                        Text("카카오로 초대장 보내기")
                            .font(Font.system(size: 14, weight: .semibold))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding()
                            .background(Color(red: 249/255, green: 224/255, blue: 1/255))
                            .foregroundColor(.black)
                            .cornerRadius(10)
                    })
                    
                    ShareLink(item: "gimifeedback://feedbackWrite/\(channelID)") {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 20))
                            .padding()
                            .background(Color(UIColor.systemGray5))
                            .frame(width: 48, height: 48)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .frame(maxHeight: 48)
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            Button("홈으로 돌아가기") {
                router.popToRootView()
            }
            .buttonStyle(.gimiPrimary)
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    ChannelCreateCompleteView(channelID: "1234") { }
}
