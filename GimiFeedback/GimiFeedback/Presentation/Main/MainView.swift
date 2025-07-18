//
//  MainView.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/15/25.
//

import SwiftUI

struct MainView: View {
    @StateObject var router: MainNavigationRouter
    @ObservedObject var notificationRouter: NotificationViewModel
    
    init(notificationRouter: NotificationViewModel) {
        _router = StateObject(wrappedValue: MainNavigationRouter())
        self.notificationRouter = notificationRouter
    }
    
    var body: some View {
        NavigationStack(path: $router.destinations) {
            ChannelListView()
                .navigationDestination(for: MainNavigationDestination.self) { destination in
                    MainNavigationRoutingView(destination: destination)
                }
        }
        .environmentObject(router)
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
}

#Preview {
    MainView(notificationRouter: NotificationViewModel())
}
