//
//  TitleSectionView.swift
//  GimiFeedback
//
//  Created by 조운경 on 7/25/25.
//

import SwiftUI

struct TitleSectionView: View {
    @Binding var title: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("제목")
                    .font(.title1)
                
                Text("피드백 채널의 재목을 작성해주세요")
                    .font(.footnote)
                    .foregroundColor(.gray400)
            }
            
            TextField("", text: $title)
                .textFieldStyle(.gimiTitle)
        }
        .padding(.vertical, 16)
    }
}

#Preview {
    TitleSectionView(title: .constant("1234"))
}
