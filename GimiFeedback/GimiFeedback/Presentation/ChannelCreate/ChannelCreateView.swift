//
//  ChannelCreateView.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/14/25.
//

import SwiftUI

struct ChannelCreateView: View {
    enum Field: Hashable {
        case title
        case description
    }
    @StateObject var viewModel: ChannelCreateViewModel
    @EnvironmentObject var router: MainNavigationRouter
    
    @FocusState private var focusedField: Field?
    
    @State private var isShowCreateAlert: Bool = false
    @State private var buttonDisabled: Bool = true
    @State private var messageContent: String = "입력한 정보로 채널을 생성합니다.\n설명이 없다면 기본 문구가 사용돼요."
    
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
                        .textFieldStyle(.gimiTitle)
                        .focused($focusedField, equals: .title)
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
                    
                    TextEditor(text: $viewModel.description)
                        .focused($focusedField, equals: .description)
                        .textEditorBase(type: .medium)
                        .textEditorLimit(text: $viewModel.description, maximumText: 100)
                        .textEditorPlaceholder(placeholder: "자우롭게 피드백을 남겨주세요", text: $viewModel.description)
                }
                .padding(.vertical, 16)
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .gimiNavigationBar(title: "채널 생성하기")
        .alert("채널 생성하기", isPresented: $isShowCreateAlert) {
            Button("취소", role: .cancel) { }
            Button("확인") {
                viewModel.send(.createFeedbackChannel)
            }
        } message: {
            Text(messageContent)
        }
        .background {
            Color.white
                .onTapGesture {
                    focusedField = nil
                }
        }
        .safeAreaInset(edge: .bottom) {
            Button("완료하기") {
                isShowCreateAlert = true
            }
            .buttonStyle(.gimiPrimary)
            .disabled(buttonDisabled)
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
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
        .onChange(of: viewModel.description) { _, newValue in
            if !newValue.isEmpty {
                messageContent = "입력한 정보로 채널을 생성합니다."
            } else {
                messageContent = "입력한 정보로 채널을 생성합니다.\n설명이 없다면 기본 문구가 사용돼요."
            }
        }
    }
}

#Preview {
    ChannelCreateView()
}
