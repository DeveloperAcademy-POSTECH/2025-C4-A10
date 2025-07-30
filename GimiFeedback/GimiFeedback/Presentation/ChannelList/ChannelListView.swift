//
//  HomeView.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/15/25.
//

import SwiftUI

struct ChannelListView: View {
    @EnvironmentObject var router: MainNavigationRouter
    @StateObject var viewModel: ChannelListViewModel
    
    init() {
        _viewModel = StateObject(wrappedValue: .init())
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HeaderView()
                
                if !viewModel.isChannelListLoading {
                    ChannelGridView(viewModel: viewModel)
                }
                
                Spacer()
            }

            if viewModel.isChannelListLoading {
                LoadingView(text: "피드백 로딩 중...")
            } else if !viewModel.isChannelListLoading
                        && viewModel.channelList.isEmpty {
                ListEmptyView()
            }
        }
        .padding(.horizontal, 24)
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                BottomView(totalFeedbackCount: viewModel.totalFeedbackCount)
            }
        }
        .toolbarBackground(.bottomBar, for: .bottomBar)
        .toolbarBackground(.visible, for: .bottomBar)
        .overlay(alignment: .bottom) {
            if !viewModel.isShowToast {
                GuideToastView(viewModel: viewModel)
            }
        }
        .onAppear {
            viewModel.send(.fetchChannelList)
        }
    }
}

#Preview {
    ChannelListView()
        .environmentObject(MainNavigationRouter())
}
