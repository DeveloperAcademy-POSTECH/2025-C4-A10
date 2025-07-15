//
//  NavigationRoutingView.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/15/25.
//

import SwiftUI

struct StartNavigationRoutingView: View {
    
    @State var destination: StartNavigationDestination
    
    var body: some View {
        Group {
            switch destination {
            case .inputCode:
                InputCodeView()
            case .login:
                LoginView()
            case .feedbackWriteComplete:
                // TODO: 피드백 완료 이동
                EmptyView()
            case .feedbackWrite:
                // TODO: 피드백 생성 이동
                EmptyView()
            }
        }
    }
}
