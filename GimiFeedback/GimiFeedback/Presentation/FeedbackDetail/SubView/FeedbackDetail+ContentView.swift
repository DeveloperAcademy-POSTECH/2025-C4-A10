//
//  FeedbackDetail+ContentView.swift
//  GimiFeedback
//
//  Created by 승찬 on 7/28/25.
//

import SwiftUI

enum ContentType {
    case trans
    case original
}

extension FeedbackDetailView {
    struct ContentView: View {
        let detail: FeedbackContent
        let contentType: ContentType
        let contentText: String? // 원본 내용 또는 변환된 내용 (변환된 내용은 처음에 없을 수도 있음)
        let buttonText: String
        let onTapToggle: () -> Void // 순화 <-> 원본
        let onTapContent: () -> Void // 커버로 돌아가는

        var body: some View {
            VStack(spacing: 0) {
                if contentType == .trans && contentText == nil {
                    VStack(spacing: 12) {
                        ProgressView()
                            .frame(width: 30, height: 30)
                        Text("텍스트 변환중입니다...")
                            .font(.callout)
                            .foregroundStyle(detail.spicyColor)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(contentType == .original ? "원문" : "AI 순화")
                                .font(.footnote)
                                .foregroundStyle(.gray600)
                            
                            Spacer()
                            
                            Text(detail.spicyLabel)
                                .font(.footnote)
                                .foregroundStyle(detail.spicyColor)
                        }
                        .padding(.top, 12)
                        
                        Text(contentText ?? "")
                            .font(.callout)
                            .foregroundStyle(.gray900)
                            .multilineTextAlignment(.leading)
                            .padding(.bottom, 16)
                    }
                    .padding(.horizontal, 16)
                    .onTapGesture {
                        onTapContent()
                    }
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(detail.fillColor)

                    Button(action: onTapToggle) {
                        Text(buttonText)
                            .font(.callout2)
                            .foregroundStyle(detail.spicyColor)
                            .padding(.horizontal, 60)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                    }
                    .frame(height: 55)
                }
            }
            .frame(minHeight: 160)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(detail.backgroundColor)
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .inset(by: 0.5)
                            .stroke(.gray50, lineWidth: 1)
                    )
            )
        }

    }
}
