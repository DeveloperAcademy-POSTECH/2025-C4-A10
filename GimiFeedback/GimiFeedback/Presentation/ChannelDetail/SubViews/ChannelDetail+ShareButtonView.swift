//
//  ChannelDetail+ShareButtonView.swift
//  GimiFeedback
//
//  Created by 승찬 on 7/29/25.
//

import SwiftUI

enum ShareType {
    case system(String)
    case asset(String)
}

extension ChannelDetailView {
    struct ShareButtonView: View {
        let icon: ShareType
        let text: String
        let onTapAction: () -> Void

        var body: some View {
            Group {
                switch icon {
                case .system(let imageName):
                    HStack(spacing: 16) {
                        Circle()
                            .fill(Color.primaryLighten300)
                            .frame(width: 44, height: 44)
                            .overlay(alignment: .center) {
                                Image(systemName: imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 23, height: 24)
                                    .padding(7)
                                    .foregroundStyle(.brandGreen300)
                            }
                        
                        Text(text)
                            .font(.callout)
                            .foregroundStyle(.gray900)
                        
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .frame(height: 64)
                    .background(.white)
                    .onTapGesture {
                        onTapAction()
                    }
                    
                case .asset(let imageName):
                    HStack(spacing: 16) {
                        Circle()
                            .fill(Color.primaryLighten300)
                            .frame(width: 44, height: 44)
                            .overlay(alignment: .center) {
                                Image(imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 32, height: 30)
                                    .padding(6)
                            }

                        Text(text)
                            .font(.callout)
                            .foregroundStyle(.gray900)
                        
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .frame(height: 64)
                    .background(.white)
                    .onTapGesture {
                        onTapAction()
                    }
                }
            }
        }
    }
}
