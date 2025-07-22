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
    @EnvironmentObject var router: MainNavigationRouter
    
    init() {
        _viewModel = StateObject(wrappedValue: .init())
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("제목")
                        .font(Font.system(size: 17, weight: .regular))
                    
                    TextField("", text: $viewModel.title)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(5)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("설명")
                        .font(Font.system(size: 17, weight: .regular))
                    
                    TextEditor(text: $viewModel.description)
                        .scrollContentBackground(.hidden)
                        .frame(height: 132)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(5)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            
            Spacer()
            
            Button(action: {
                isShowCreateAlert = true
            }, label: {
                Text("완료하기")
                    .font(Font.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: 66)
                    .background(Color.black)
                    .cornerRadius(20)
                    .padding()
            })
            .disabled(viewModel.title.isEmpty || viewModel.description.isEmpty)
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
    }
}

#Preview {
    ChannelCreateView()
}
