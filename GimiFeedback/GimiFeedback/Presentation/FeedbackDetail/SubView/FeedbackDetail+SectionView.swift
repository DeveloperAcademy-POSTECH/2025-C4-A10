//
//  FeedbackDetail+SectionView.swift
//  GimiFeedback
//
//  Created by 승찬 on 7/25/25.
//

import SwiftUI

extension FeedbackDetailView {
    struct SectionView: View {
        let type: FeedbackContentType
        @Binding var details: [FeedbackContent]
        let onReveal: (FeedbackContent) -> Void
        let onTapTrans: (FeedbackContent) -> Void

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(type.title)
                    .font(.title1)
                
                if details.isEmpty {
                    Text("작성된 내용이 없습니다.")
                        .font(.callout)
                        .foregroundStyle(.gray400)
                }

                ForEach($details, id: \.id) { $detail in
                    LazyVStack(spacing: 16) {
                        FeedbackRowView(
                            detail: $detail,
                            onReveal: { onReveal($0) },
                            onTapTrans: { onTapTrans(detail) })
                    }
                    .padding(.top, 8)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
        }

    }
}
