//
//  ChannelEditView.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/15/25.
//

import SwiftUI

struct ChannelEditView: View {
    @StateObject var viewModel: ChannelEditViewModel
    @State private var isShowCreateAlert: Bool = false
    @EnvironmentObject var router: MainNavigationRouter
    
    init(channelItem: FeedbackChannel) {
        _viewModel = StateObject(wrappedValue: .init(channelItem: channelItem))
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("제목")
                        .font(Font.system(size: 17, weight: .regular))
                    
                    TextField("", text: $viewModel.channelItem.channelTitle)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(5)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("설명")
                        .font(Font.system(size: 17, weight: .regular))
                    
                    TextEditor(text: $viewModel.channelItem.content)
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
//            .disabled(viewModel.title.isEmpty || viewModel.description.isEmpty)
        }
        .navigationTitle("채널 수정하기")
        .navigationBarTitleDisplayMode(.inline)
        .alert("채널 수정하기", isPresented: $isShowCreateAlert) {
            Button("취소", role: .cancel) { }
            Button("확인") {
                viewModel.send(.updateFeedbackChannel)
            }
        } message: {
            Text("이대로 수정하겠습니까?")
        }
        .onChange(of: viewModel.isUpdate) { _, new in
            if new == true {
                router.pop()
            }
        }
    }

}
