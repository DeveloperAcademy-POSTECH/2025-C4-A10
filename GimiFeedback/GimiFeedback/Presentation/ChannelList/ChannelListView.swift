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
    
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    
    init() {
        _viewModel = StateObject(wrappedValue: .init())
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HeaderView(router: router)
                
                ScrollView {
                    LazyVGrid(columns: columns, alignment: .center, spacing: 32) {
                        ForEach(viewModel.channelList) { item in
                            Button {
                                router.push(to: .channelDetail(channelItem: item.channel))
                            } label: {
                                ListItemView(item: item)
                            }
                        }
                    }
                }
            }

            if viewModel.isChannelListLoading {
                LoadingView(text: "피드백 로딩 중...")
            } else if !viewModel.isChannelListLoading
                        && viewModel.channelList.isEmpty {
                ListEmptyView()
            }
        }
        .padding(.horizontal, 24)
        .overlay(alignment: .bottom) {
            HStack {
                Spacer()
                SpeechBubbleView(message: "여기서 채널을 생성할 수 있어요")
            }
            .padding(.horizontal, -14)
        }
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
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
                    Text("\(viewModel.totalFeedbackCount)개의 피드백")
                        .font(.caption1)
                        .foregroundStyle(.black)
                })
            }
        }
        .toolbarBackground(.bottomBar, for: .bottomBar)
        .toolbarBackground(.visible, for: .bottomBar)
        .onAppear {
            viewModel.send(.fetchChannelList)
        }
    }
}

#Preview {
    ChannelListView()
        .environmentObject(MainNavigationRouter())
}
