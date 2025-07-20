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
    
    init() {
        let router = MainNavigationRouter()
        _router = StateObject(wrappedValue: router)
        _viewModel = StateObject(wrappedValue: MainViewModel(router: router))
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
        }
        .environmentObject(router)
    }
}

#Preview {
    MainView()
}
