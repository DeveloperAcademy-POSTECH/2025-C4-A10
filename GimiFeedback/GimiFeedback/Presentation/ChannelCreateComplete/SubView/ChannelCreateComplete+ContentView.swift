//
//  ChannelCreateComplete+ContentView.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/30/25.
//

import SwiftUI

extension ChannelCreateCompleteView {
    struct ContentView: View {
        var body: some View {
            VStack(alignment: .center, spacing: 12) {
                Image(systemName: "checkmark")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(.bottom, 4)
                
                Text("피드백 채널을 만들었어요")
                    .font(.title1)
                    .foregroundStyle(.black)
                
                Text("아래 링크를 복사하거나 공유해서\n피드백을 요청하세요")
                    .font(.callout)
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.center)
            }
        }
    }
}
