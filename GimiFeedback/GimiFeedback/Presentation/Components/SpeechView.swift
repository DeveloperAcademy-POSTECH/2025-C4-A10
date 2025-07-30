//
//  SpeechView.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/22/25.
//

import SwiftUI

struct SpeechBubbleView: View {
    let message: String
    var isTailTop: Bool = false

    @State private var bubbleWidth: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            if isTailTop {
                TriangleTailView(width: bubbleWidth, isTop: true)
            }

            MessageBodyView(message: message, bubbleWidth: $bubbleWidth)

            if !isTailTop {
                TriangleTailView(width: bubbleWidth, isTop: false)
            }
        }
    }
}

extension SpeechBubbleView {
    
    // MARK: 메시지 뷰
    
    struct MessageBodyView: View {
        let message: String
        @Binding var bubbleWidth: CGFloat

        var body: some View {
            VStack(spacing: 0) {
                Text(message)
                    .foregroundColor(.brandGreen100)
                    .font(.footnote)
                    .lineSpacing(5)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(
                        GeometryReader { geometry in
                            Color.clear
                                .onAppear {
                                    bubbleWidth = geometry.size.width
                                }
                                .onChange(of: geometry.size.width) { _, newValue in
                                    bubbleWidth = newValue
                                }
                        }
                    )
            }
            .background(Color.primaryDarken100)
            .cornerRadius(12)
            .padding(.horizontal, 24)
        }
    }
    
    // MARK: 삼각형 뷰
    
    struct TriangleTailView: View {
        let width: CGFloat
        let isTop: Bool

        var body: some View {
            Triangle()
                .fill(.primaryDarken100)
                .frame(width: 18, height: 12)
                .rotationEffect(.degrees(isTop ? 180 : 0))
                .offset(x: width / 2 - 24 - 9, y: isTop ? 2 : -2)
        }
    }
    
    // MARK: 삼각형 그리는 부분
    
    struct Triangle: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            
            return path
        }
    }
}

#Preview {
    VStack {
        SpeechBubbleView(message: "안녕")
            .padding()
            .background(Color.gray.opacity(0.2))
        
        SpeechBubbleView(message: "여기서 채널을 생성할 수 있어요.")
            .padding()
            .background(Color.gray.opacity(0.2))
        
        SpeechBubbleView(message: "안녕하세요 테스트입니다.\n안녕하세요 테스트입니다.")
            .padding()
            .background(Color.gray.opacity(0.2))
        
        SpeechBubbleView(message: "여기서 채널을 생성할 수 있어요.", isTailTop: true)
            .padding()
            .background(Color.gray.opacity(0.2))
    }
}
