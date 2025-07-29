//
//  LoadingView.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/29/25.
//

import SwiftUI

struct LoadingView: View {
    
    var body: some View {
        VStack(spacing: 24) {
            ProgressView()
                .progressViewStyle(.circular)
                .scaleEffect(1.5)
                .foregroundColor(.gray400)
            Text("피드백을 전송중이에요...")
                .font(.title3)
                .foregroundStyle(.gray400)
        }
        
    }
}

#Preview {
    LoadingView()
}
