//
//  FeedbackWrite+HeaderView.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/27/25.
//

import SwiftUI

extension FeedbackWriteView {
    struct HeaderView: View {
        let userName: String
        @State private var isPresentingInfo: Bool = false
        
        var body: some View {
            HStack {
                Text("\(userName)를 위해 피드백해주세요")
                    .font(.title1)
                
                Spacer()
                
                Button {
                    isPresentingInfo = true
                } label: {
                    Image(systemName: "questionmark.circle")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.black)
                }
            }
            .sheet(isPresented: $isPresentingInfo) {
                FeedbackWriteView.InfoView {
                    isPresentingInfo = false
                }
                .presentationDetents([.height(655)])
                .presentationDragIndicator(.visible)
            }
        }
    }
}

#Preview {
    FeedbackWriteView.HeaderView(userName: "Yoshi")
        .customPadding()
}
