//
//  FeedbackDetail+DescriptionView.swift
//  GimiFeedback
//
//  Created by 승찬 on 7/26/25.
//

import SwiftUI

extension FeedbackDetailView {
    struct DescriptionView: View {
        let writePerson: String
        let date: String
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text("\(writePerson)의 피드백")
                    .font(.title1)
                    .foregroundStyle(.black)
                
                Text("\(date)")
                    .font(.caption2)
                    .foregroundStyle(.gray600)
            }
            .customPadding()
            .padding(.vertical, 4)
            
            Rectangle()
                .foregroundStyle(.gray50)
                .frame(height: 8)
                .frame(maxWidth: .infinity)
        }
    }
}
