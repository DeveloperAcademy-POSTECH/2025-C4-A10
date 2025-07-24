//
//  ChannelCreateView.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/14/25.
//

import SwiftUI

struct ChannelCreateView: View {

    @StateObject var viewModel: ChannelCreateViewModel
    @State private var isShowCreateAlert: Bool = false
    @State private var buttonDisabled: Bool = true
    @EnvironmentObject var router: MainNavigationRouter
    
    init() {
        _viewModel = StateObject(wrappedValue: .init())
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("제목")
                            .font(.title1)
                        
                        Text("피드백 채널의 재목을 작성해주세요")
                            .font(.footnote)
                            .foregroundColor(.gray400)
                    }
                    
                    TextField("", text: $viewModel.title)
                        .padding()
                        .background(.gray50)
                        .cornerRadius(12)
                }
                .padding(.vertical, 16)
                
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("설명")
                            .font(.title1)
                        
                        Text("피드백을 받고 싶은 내용에 대해 설명해주세요")
                            .font(.footnote)
                            .foregroundColor(.gray400)
                    }
                    
                    ZStack(alignment: .topLeading) {
                        let placeholder = "자유롭게 피드백을 남겨주세요"
                        
                        TextEditor(text: $viewModel.description)
                            .scrollContentBackground(.hidden)
                            .frame(height: 154)
                            .padding(.top, 12)
                            .padding(.leading, 16)
                            .background(.gray50)
                            .cornerRadius(12)
                        
                        if viewModel.description.isEmpty {
                            Text(placeholder)
                                .font(.callout)
                                .foregroundColor(.gray100)
                                .padding(.top, 12)
                                .padding(.leading, 16)
                        }
                    }
                }
                .padding(.vertical, 16)
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            Button(action: {
                isShowCreateAlert = true
            }, label: {
                Text("완료하기")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: 64)
                    .background(buttonDisabled ? .gray100 : .primaryBase)
                    .cornerRadius(12)
                    .padding()
            })
            .disabled(buttonDisabled)
        }
        .gimiNavigationBar(title: "채널 생성하기")
        .alert("채널 생성하기", isPresented: $isShowCreateAlert) {
            Button("취소", role: .cancel) { }
            Button("확인") {
                viewModel.send(.createFeedbackChannel)
            }
        } message: {
            Text("이대로 생성하겠습니까?")
        }
        .onChange(of: viewModel.createdChannelID) { _, newValue in
            if let id = newValue {
                router.push(
                    to: .feedbackChannelCreateComplete(channelID: id)
                )
            }
        }
        .onChange(of: viewModel.title) { _, newValue in
            if newValue.isEmpty {
                buttonDisabled = true
            } else {
                buttonDisabled = false
            }
        }
    }
}

#Preview {
    ChannelCreateView()
}
