//
//  FeedbackDetail+FeedbackRowView.swift
//  GimiFeedback
//
//  Created by 승찬 on 7/25/25.
//

import SwiftUI

extension FeedbackDetailView {
    struct FeedbackRowView: View {
        @Binding var detail: FeedbackContent
        let onReveal: (FeedbackContent) -> Void
        let onTapTrans: () -> Void // transContent 값이 있으면 그냥 토글, 없으면 gpt로 변환
        
        var body: some View {
            ZStack {
                switch detail.cardState {
                case .cover:
                    CoverView(
                        detail: detail,
                        onTapTrans: {
                            /// 순화한적 없으면 GPT 불러오기
                            if detail.transContent == nil {
                                onTapTrans()
                            }
                            detail.cardState = .trans
                            onReveal(detail)
                        },
                        onTapOriginalContent: {
                            detail.cardState = .original
                            onReveal(detail)
                        }
                    )

                case .trans:
                    ContentView(
                        detail: detail,
                        contentType: .trans,
                        contentText: detail.transContent,
                        buttonText: "원문 보기",
                        onTapToggle: {
                            detail.cardState = .original
                            onReveal(detail)
                        },
                        onTapContent: {
                            detail.cardState = .cover
                            onReveal(detail)
                        }
                    )

                case .original:
                    ContentView(
                        detail: detail,
                        contentType: .original,
                        contentText: detail.content,
                        buttonText: "순화된 버전 보기",
                        onTapToggle: {
                            if detail.transContent == nil {
                                onTapTrans()
                            }
                            detail.cardState = .trans
                            onReveal(detail)
                        },
                        onTapContent: {
                            detail.cardState = .cover
                            onReveal(detail)
                        }
                    )
                }
            }
        }
    }
}
