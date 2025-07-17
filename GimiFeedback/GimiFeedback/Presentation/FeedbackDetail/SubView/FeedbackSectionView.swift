//
//  FeedbackSectionView.swift
//  GimiFeedback
//
//  Created by 조운경 on 7/17/25.
//

import SwiftUI

struct FeedbackSectionView: View {
    let type: FeedbackContentType
    var title: String {
        switch type {
        case .keep:
            return "Keep"
        case .problem:
            return "Problem"
        case .try:
            return "Try"
        case .other:
            return "Other"
        }
    }
    @Binding var details: [FeedbackContent]
    let onReveal: (FeedbackContent) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .padding(.bottom, 4)
            
            ForEach($details, id: \.content) { $detail in
                VStack(alignment: .leading, spacing: 4) {
                    if detail.visiable {
                        VStack(spacing: 4) {
                            Text("매운맛 \(detail.spicy)단계에요")
                            
                            Text(detail.content)
                        }
                    } else {
                        ZStack {
                            Text(detail.content)
                                .blur(radius: 6)
                            
                            VStack(spacing: 4) {
                                Text("매운맛 \(detail.spicy)단계에요")
                                
                                Button(action: {
                                    onReveal(detail)
                                }) {
                                    Text("원문 확인")
                                }
                            }
                        }
                    }
                    
                }
            }
        }
    }
}

#Preview {
    var sampleFeedbackContents: [FeedbackContent] = [
        FeedbackContent(
            content: "사용자 온보딩 플로우가 명확해서 이해하기 쉬웠어요.",
            spicy: 1,
            visiable: false,
            type: .keep
        ),
        FeedbackContent(
            content: "피드 로딩 시간이 너무 길어져서 기다리기 힘들어요.",
            spicy: 4,
            visiable: false,
            type: .problem
        ),
        FeedbackContent(
            content: "다양한 로그인 옵션을 제공하면 접근성이 더 좋아질 것 같아요.",
            spicy: 2,
            visiable: false,
            type: .try
        ),
        FeedbackContent(
            content: "앱 테마 색상을 계절에 따라 바꾸는 것도 재미있을 것 같아요.",
            spicy: 2,
            visiable: false,
            type: .other
        ),
        FeedbackContent(
            content: "고객센터 응답이 빨라서 좋았습니다. 감사합니다.",
            spicy: 1,
            visiable: false,
            type: .keep
        ),
        FeedbackContent(
            content: "알림 설정이 복잡해서 원하는 항목만 선택하기 어려웠어요.",
            spicy: 3,
            visiable: false,
            type: .problem
        ),
        FeedbackContent(
            content: "이벤트 기능을 시도해보면 사용자 참여율이 높아질 것 같아요.",
            spicy: 3,
            visiable: false,
            type: .try
        ),
        FeedbackContent(
            content: "툴팁에 이모지를 넣으면 더 직관적으로 느껴질 수 있을 듯해요.",
            spicy: 1,
            visiable: false,
            type: .try
        )
    ]
    
    @State var feedbacks = sampleFeedbackContents
    
    FeedbackSectionView(type: .keep, details: $feedbacks, onReveal: { detail in
        if let index = feedbacks.firstIndex(where: { $0.id == detail.id }) {
            feedbacks[index].visiable = true
        }
    })
}
