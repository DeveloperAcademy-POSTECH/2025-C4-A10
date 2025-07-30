//
//  LoadingView.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/29/25.
//

import SwiftUI

struct LoadingView: View {
    let text: String
    
    var body: some View {
        VStack(spacing: 24) {
            ProgressView()
                .progressViewStyle(.circular)
                .scaleEffect(1.5)
                .foregroundColor(.gray400)
            Text(text)
                .font(.title3)
                .foregroundStyle(.gray400)
        }
    }
}

#Preview {
    LoadingView(text: "Test..")
}
