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
    
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
    
    init() {
        _viewModel = StateObject(wrappedValue: ChannelListViewModel())
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, alignment: .center, spacing: 32) {
                ForEach(viewModel.channelList) { item in
                    Button {
                        router.push(to: .channelDetail(channelItem: item.channel))
                    } label: {
                        ChannelListItemView(item: item)
                    }
                }
            }
        }
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
        .padding(.top, 32)
        .navigationTitle("기미 피드백")
        .onAppear {
            viewModel.send(.fetchChannelList)
        }
    }
}
