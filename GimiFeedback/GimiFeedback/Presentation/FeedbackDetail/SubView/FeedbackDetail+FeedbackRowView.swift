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
        @State private var isPressed: Bool = false
        @State private var isRecognizing: Bool = false
        let onTapTrans: () -> Void
        
        var body: some View {
            ZStack {
                CoverView(detail: detail, isPressed: isPressed)
                
                ContentView(detail: detail, onTapTrans: { onTapTrans() })
            }
            .padding(.horizontal, 16)
            .frame(height: detail.visiable ? nil : 153)
            /// minimumDuration: 몇 초 동안 눌러야 하는가
            /// maximuDistane
            /// - 누르고 나서 (누른 상태를 유지한채)
            /// 손가락을 화면의 다른 곳으로 이동해도 누르고 있다고 인정하는 범위
            .onLongPressGesture(
                minimumDuration: 2,
                maximumDistance: 100
            ) {
                /// 누르기가 끝났을 때 실행되는 코드
                guard detail.visiable == false else { return }
                detail.visiable = true
                onReveal(detail)
            }
            
            /// 누르기 시작할때 실행되는 코드
            onPressingChanged: { isPressing in
                if isPressing {
                    isRecognizing = true
                    
                    /// 최소 시간 이상 눌렀는가
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        if isRecognizing {
                            withAnimation(.easeInOut(duration: 1.5)) {
                                isPressed = true
                            }
                        }
                    }
                }
                /// 만약 누르다가 손을 뗐을 때
                else {
                    isRecognizing = false
                    
                    /// 정해진 시간만큼 다 눌렀는지 확인하고, 아니라면 누르고 있지 않다는 상태로 변경
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        if !detail.visiable {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isPressed = false
                            }
                        }
                    }
                }
            }
            .onTapGesture {
                if detail.visiable {
                    isPressed = false
                    detail.visiable = false
                    onReveal(detail)
                }
            }
        }
    }
}

extension FeedbackDetailView {
    struct CoverView: View {
        let detail: FeedbackContent
        let isPressed: Bool
        
        var body: some View {
            Rectangle()
                .fill(detail.fillColor)
                .frame(maxWidth: isPressed ? .infinity : .zero)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(detail.backgroundColor)
                .clipShape(.rect(cornerRadius: 18))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .inset(by: 0.5)
                        .stroke(.gray50, lineWidth: 1)
                )
                .overlay(alignment: .center) {
                    Text("\(detail.spicyLabel) 피드백이에요")
                        .font(.callout)
                        .fontWeight(.bold)
                        .foregroundStyle(detail.spicyColor)
                }
                .frame(height: 153)
                .opacity(detail.visiable ? .zero : 1)
        }
    }
}

extension FeedbackDetailView {
    struct ContentView: View {
        let detail: FeedbackContent
        let onTapTrans: () -> Void
        
        var isActive: Bool {
            detail.transContent != nil
        }
        
        var body: some View {
            VStack(spacing: .zero) {
                VStack(spacing: 16) {
                    /// 상단 피드백 영역 => 아마 이미지로 대체 할 듯 (조건을 줘가지고)
                    /// spicy 정도에 따라서 표현
                    Image("\(detail.spicyImage)")
                        .resizable()
                        .frame(width: 340, height: 65)
                        .padding(.top, 8)
                    
                    /// 텍스트 메시지
                    Text(detail.content)
                        .font(.callout)
                        .foregroundColor(.gray900)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 8)
                        .padding(.bottom, 16)
                    
                    Button(action: {
                        onTapTrans()
                    }) {
                        Text("순화")
                    }
                    .disabled(isActive)
                    
                    if let transContent = detail.transContent  {
                        Text(transContent)
                            .font(.callout)
                            .foregroundStyle(.blue)
                    }
                }
                .padding(.horizontal, 8)
                
            }
            .frame(minHeight: .zero)
            .background(Color.white)
            .clipShape(.rect(cornerRadius: 18))
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .inset(by: 0.5)
                    .stroke(.gray50, lineWidth: 1)
            )
            .opacity(detail.visiable ? 1 : .zero)
        }
    }
}
