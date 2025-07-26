//
//  ToastView.swift
//  GimiFeedback
//
//  Created by 승찬 on 7/26/25.
//

import SwiftUI

enum ToastStyle {
    case basic(message: String)
    case guide
}

struct ToastView: View {
    let style: ToastStyle
    @Binding var isPresented: Bool
    
    var body: some View {
        content
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation(.easeIn(duration: 0.3)) {
                        isPresented = false
                    }
                }
            }
    }
    
    @ViewBuilder
    var content: some View {
        switch style {
        case .basic(let message):
            Text(message)
                .font(.system(size: 13, weight: .medium))
                .font(.caption1)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
                .background(.gray900.opacity(0.9))
                .clipShape(.rect(cornerRadius: 27.5))
                .frame(minHeight: 56)
            
        case .guide:
            VStack(alignment: .center, spacing: 34) {
                Image("PopUp")
                    .resizable()
                    .frame(width: 140, height: 140)

                Text("원문을 확인하려면 길게 누르세요")
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 31)
            .padding(.vertical, 34)
            .background(.gray900.opacity(0.75))
            .clipShape(.rect(cornerRadius: 12))
            .frame(width: 283, height: 267)
        }
    }
}


#Preview {
    VStack(spacing: 32) {
        ToastView(style: .guide, isPresented: .constant(true))
        
        ToastView(style: .basic(message: "최소 10자 이상 작성해주세요."), isPresented: .constant(true))
        
        ToastView(style: .basic(message: "코드가 복사되었어요."), isPresented: .constant(true))
    }
}
