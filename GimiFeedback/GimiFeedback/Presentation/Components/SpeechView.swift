//
//  SpeechView.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/22/25.
//

import SwiftUI

struct SpeechBubbleView: View {
    let message: String
    
    @State private var bubbleWidth: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Text 부분
            VStack(spacing: 0) {
                Text(message)
                    .foregroundColor(.brandGreen100)
                    .lineSpacing(5)
                    .padding(16)
                    .background(GeometryReader { geometry in
                        Color.clear
                            .onAppear {
                                bubbleWidth = geometry.size.width
                            }
                            .onChange(of: geometry.size.width) { _, newValue in
                                bubbleWidth = newValue
                            }
                    })
            }
            .background(Color.primaryDarken100)
            .cornerRadius(12)
            .padding(.horizontal, 24)
            
            // 꼬리 부분
            Triangle()
                .fill(.primaryDarken100)
                .frame(width: 18, height: 12)
                .offset(x: bubbleWidth / 4, y: -2) // 메시지 크기에 따른 변경
        }
    }
}

// MARK: - Triangle

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
    }
}
