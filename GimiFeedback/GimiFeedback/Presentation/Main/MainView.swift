//
//  MainView.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/15/25.
//

import SwiftUI

struct MainView: View {
    @StateObject var router: MainNavigationRouter
    @StateObject private var viewModel: MainViewModel
    @ObservedObject var notificationRouter: NotificationViewModel
    
    init(notificationRouter: NotificationViewModel) {
        _router = StateObject(wrappedValue: MainNavigationRouter())
        _viewModel = StateObject(wrappedValue: .init())
        self.notificationRouter = notificationRouter
    }
    
    var body: some View {
        NavigationStack(path: $router.destinations) {
            ChannelListView()
                .navigationDestination(for: MainNavigationDestination.self) { destination in
                    MainNavigationRoutingView(destination: destination)
                }
                .onOpenURL { url in
                    viewModel.send(.handleDeepLink(url))
                }
                .onChange(of: viewModel.channel) { _, newValue in
                    if let channel = newValue {
                        router.push(to: .channelDetail(channelItem: channel))
                        viewModel.send(.resetChannel)
                    }
                }
                .onAppear {
                    notificationRouter.send(.fetchFeedback)
                }
                .onChange(of: notificationRouter.feedback) { _, newValue in
                    if let feedback = newValue {
                        router.push(to: .feedbackDetail(feedback: feedback))
                        notificationRouter.send(.resetFeedback)
                    }
                }
        }
        .environmentObject(router)
    }
}

#Preview {
    MainView(notificationRouter: NotificationViewModel())
}
