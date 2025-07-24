//
//  ChannelEditView.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/15/25.
//

enum FocusField {
    case title
    case content
}

import SwiftUI

struct ChannelEditView: View {
    @StateObject var viewModel: ChannelEditViewModel
    @State private var isShowCreateAlert: Bool = false
    @EnvironmentObject var router: MainNavigationRouter
    
    @FocusState private var focusField: FocusField?
    
    init(channelItem: FeedbackChannel) {
        _viewModel = StateObject(wrappedValue: .init(channelItem: channelItem))
    }
    
    private var isActive: Bool {
        // 제목은 비어있으면 안됌
        let trimmed = viewModel.channelItem.channelTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }

        /// 이전과 하나라도 다른 값이어야 함
        return viewModel.channelItem.channelTitle != viewModel.originalChannelTitle
        || viewModel.channelItem.content != viewModel.originalContent
    }

    var body: some View {
        VStack(spacing: .zero) {
            TitleView(
                text: $viewModel.channelItem.channelTitle,
                field: .title,
                focusState: $focusField
            )
            
            ContentView(
                text: $viewModel.channelItem.content,
                field: .content,
                focusState: $focusField)
            
            Spacer()
            
            Button("저장하기") {
             isShowCreateAlert = true
            }
            .buttonStyle(.gimiPrimary)
            .disabled(!isActive)
        }
        .padding(.horizontal, 20)
        .background(.white)
        .onTapGesture {
            focusField = nil
        }
        
        .gimiNavigationBar(title: "채널 수정하기")
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

#Preview {
    ChannelEditView(channelItem: .init(userID: "d", channelTitle: "C4", content: "dklfndklfndklfndklf"))
}
