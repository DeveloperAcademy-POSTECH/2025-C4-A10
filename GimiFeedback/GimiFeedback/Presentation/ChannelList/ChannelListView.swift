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
        .padding(.horizontal, 24)
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                HStack {
                    Spacer()
                    
                    Text("\(viewModel.totalFeedbackCount)개")
                    
                    Spacer()
                    
                    Button(action: {
                        router.push(to: .feedbackChannelCreate)
                    }) {
                        Image(systemName: "folder.badge.plus")
                    }
                }
            }
        }
        .toolbarBackground(Color.gray.opacity(0.1), for: .bottomBar)
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
