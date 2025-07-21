//
//  MainView.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/15/25.
//

import SwiftUI

struct MainView: View {
    @StateObject var router: MainNavigationRouter
    @StateObject private var deepLinkViewModel: DeepLinkViewModel
    @ObservedObject var notificationRouter: NotificationViewModel
    
    init(notificationRouter: NotificationViewModel) {
        _router = StateObject(wrappedValue: .init())
        _deepLinkViewModel = StateObject(wrappedValue: .init())
        self.notificationRouter = notificationRouter
    }
    
    var body: some View {
        NavigationStack(path: $router.destinations) {
            ChannelListView()
                .navigationDestination(for: MainNavigationDestination.self) { destination in
                    MainNavigationRoutingView(destination: destination)
                }
                .onOpenURL { url in
                    deepLinkViewModel.send(.handleDeepLink(url))
                }
                .onChange(of: deepLinkViewModel.channel) { _, newValue in
                    if let channel = newValue {
                        router.push(to: .feedbackWrite(channel: channel))
                        deepLinkViewModel.send(.resetChannel)
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
