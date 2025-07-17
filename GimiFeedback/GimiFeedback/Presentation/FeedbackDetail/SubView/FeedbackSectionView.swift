//
//  FeedbackSectionView.swift
//  GimiFeedback
//
//  Created by 조운경 on 7/17/25.
//

import SwiftUI

struct FeedbackSectionView: View {
    let title: String
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

//#Preview {
//    FeedbackSectionView()
//}
