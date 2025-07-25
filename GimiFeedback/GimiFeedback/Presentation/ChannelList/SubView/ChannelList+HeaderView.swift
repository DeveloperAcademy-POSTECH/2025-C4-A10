//
//  ChannelList+HeaderView.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/25/25.
//

import SwiftUI

extension ChannelListView {
    struct HeaderView: View {
        @ObservedObject var router: MainNavigationRouter
        
        var body: some View {
            HStack {
                Image(.gimme)
                    .resizable()
                    .frame(width: 115, height: 25)
                
                Spacer()
                
                Button(action: {
                    router.push(to: .inputCode)
                }) {
                    Text("코드 입력하기")
                        .font(.system(size: 14, weight: .semibold))
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color.green.opacity(0.2))
                        .foregroundColor(.green)
                        .clipShape(Capsule())
                }
                Button(action: {
                    router.push(to: .profile)
                }) {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.green)
                }
            }
            .padding(.vertical, 16)
        }
    }
}
