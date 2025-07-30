//
//  ChannelList+bottomView.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/30/25.
//

import SwiftUI

extension ChannelListView {
    struct BottomView: View {
        @EnvironmentObject var router: MainNavigationRouter
        let totalFeedbackCount: Int
        
        var body: some View {
            HStack {
                Spacer()
                Button(action: {
                    router.push(to: .feedbackChannelCreate)
                }) {
                    Image(systemName: "folder.badge.plus")
                        .font(.system(size: 20))
                        .foregroundColor(.primaryBase)
                }
            }
            .overlay(alignment: .center, content: {
                Text("\(totalFeedbackCount)개의 피드백")
                    .font(.caption1)
                    .foregroundStyle(.black)
            })
        }
    }
}
