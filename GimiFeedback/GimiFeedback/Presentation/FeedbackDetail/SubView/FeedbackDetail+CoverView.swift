//
//  FeedbackDetail+CoverView.swift
//  GimiFeedback
//
//  Created by 승찬 on 7/28/25.
//

import SwiftUI

extension FeedbackDetailView {
    struct CoverView: View {
        let detail: FeedbackContent
        let onTapTrans: () -> Void
        let onTapOriginalContent: () -> Void

        var body: some View {
            VStack(alignment: .center, spacing: .zero) {
                Text("\(detail.spicyLabel) 피드백이에요")
                    .font(.callout)
                    .fontWeight(.bold)
                    .foregroundStyle(detail.spicyColor)
                    .padding(.horizontal, 110)
                    .padding(.vertical, 40)

                Rectangle()
                    .fill(detail.fillColor)
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)

                HStack(spacing: 0) {
                    Button(action: {
                        onTapTrans()
                    }) {
                        Text("순화된 버전 보기")
                            .font(.callout2)
                            .foregroundStyle(detail.spicyColor)
                            .padding(.horizontal, 36)
                            .padding(.vertical, 16)
                    }

                    Rectangle()
                        .fill(detail.fillColor)
                        .frame(width: 1)
                        .frame(height: 54)

                    Button(action: {
                        onTapOriginalContent()
                    }) {
                        Text("원문 보기")
                            .font(.callout2)
                            .foregroundStyle(detail.spicyColor)
                            .padding(.horizontal, 60)
                            .padding(.vertical, 16)
                    }
                }
                .frame(height: 55)
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
