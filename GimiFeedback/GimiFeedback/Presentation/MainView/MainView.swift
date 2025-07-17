//
//  MainView.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/15/25.
//

import SwiftUI

struct MainView: View {
    @StateObject var router: MainNavigationRouter
    
    init() {
        _router = StateObject(wrappedValue: MainNavigationRouter())
    }
    
    var body: some View {
        NavigationStack(path: $router.destinations) {
            ChannelListView()
                .navigationDestination(for: MainNavigationDestination.self) { destination in
                    MainNavigationRoutingView(destination: destination)
                }
                .onOpenURL { url in
                    DeepLinkManager.shared.handleFeedbackWriteDeepLink(
                        url: url,
                        router: router,
                        destination: { .feedbackWrite(channel: $0) }
                    )
                }
        }
        .environmentObject(router)
    }
}

#Preview {
    MainView()
}
