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
        _viewModel = StateObject(wrappedValue: .init())
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
        .gimiNavigationBar {
            Button(action: {
                router.push(to: .inputCode)
            }) {
                Text("코드 입력하기")
                    .font(.system(size: 14, weight: .semibold))
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Color.green.opacity(0.2))
                    .foregroundColor(.green)
                    .clipShape(Capsule())
            }
            Button(action: {
                // TODO: Profile 만들기
            }) {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .foregroundColor(.green)
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
        .onAppear {
            viewModel.send(.fetchChannelList)
        }
    }
}
