//
//  ChannelEdit+TitleView.swift
//  GimiFeedback
//
//  Created by 승찬 on 7/24/25.
//

import SwiftUI

extension ChannelEditView {
    struct TitleView: View {
        @Binding var text: String
        let field: FocusField
        var focusState: FocusState<FocusField?>.Binding
        
        var body: some View {
            VStack(alignment: .leading, spacing: 2) {
                Text("제목")
                    .font(.title1)
                    .foregroundStyle(.black)
                
                Text("피드백 채널의 제목을 작성해주세요")
                    .font(.footnote)
                    .foregroundStyle(.gray400)
                
                TextField("", text: $text)
                    .textFieldStyle(.gimiTitle)
                    .padding(.top, 10)
                    .focused(focusState, equals: field)
            }
            .padding(.vertical, 16)
        }
    }
}
