//
//  ChannelDetail+ShareSheetView.swift
//  GimiFeedback
//
//  Created by 승찬 on 7/29/25.
//

import SwiftUI

extension ChannelDetailView {
    struct ShareSheetView: View {
        @Binding var isSheet: Bool
        @Binding var isShowToast: Bool
        @Binding var isShowActivity: Bool
        let channelId: String
        let shareToKakaoAction: () -> Void

        var body: some View {
            VStack(alignment: .leading, spacing: .zero) {
                HStack {
                    Text("채널 공유하기")
                        .font(.headline)

                    Spacer()

                    Button(action: { isSheet = false }) {
                        Image(systemName: "xmark")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .padding(12)
                    }
                }
                .foregroundStyle(.black)
                .padding(.top, 24)
                .padding(.bottom, 18)

                VStack(alignment: .leading, spacing: .zero) {
                    ShareButtonView(
                        icon: .asset("KakaoIcon"),
                        text: "카카오톡 초대장 보내기",
                        onTapAction: {
                            shareToKakaoAction()
                        })

                    ShareButtonView(
                        icon: .system("document.on.document"),
                        text: "코드 복사",
                        onTapAction: {
                            withAnimation {
                                UIPasteboard.general.string = channelId
                                isShowToast = true
                            }
                        })

                    ShareButtonView(
                        icon: .system("square.and.arrow.up"),
                        text: "외부 공유",
                        onTapAction: {
                            isShowActivity = true
                        })
                    .sheet(isPresented: $isShowActivity) {
                        ActivityView(items: ["gimifeedback://feedbackWrite/\(channelId)"])
                            .presentationDetents([.medium, .large])
                    }
                }
                .frame(maxWidth: .infinity)
                .overlay(alignment: .bottom) {
                    if isShowToast {
                        ToastView(style: .basic(message: "코드가 복사되었어요."), isPresented: $isShowToast)
                            .padding(.bottom, 53)
                            .transition(.move(edge: .bottom))
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 20)
            .presentationDetents([.height(300)])
            .presentationCornerRadius(30)
        }
    }
}

struct ActivityView: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) { }
}
