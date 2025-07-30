//
//  ChannelList+GridView.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/30/25.
//

import SwiftUI

extension ChannelListView {
    struct ChannelGridView: View {
        @EnvironmentObject var router: MainNavigationRouter
        @ObservedObject var viewModel: ChannelListViewModel
        
        let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
        
        var body: some View {
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
            .refreshable {
                viewModel.send(.fetchChannelList)
            }
        }
    }
}
