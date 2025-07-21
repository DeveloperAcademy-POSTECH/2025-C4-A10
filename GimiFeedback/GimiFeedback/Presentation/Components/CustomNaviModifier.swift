//
//  CustomNaviModifier.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/21/25.
//

import SwiftUI

struct CustomNaviModifier<TrailingItems: View>: ViewModifier {
    let title: String?
    let trailingItems: TrailingItems

    var hasTrailingItems: Bool {
        !(trailingItems is EmptyView)
    }

    func body(content: Content) -> some View {
        content
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    if let title = title {
                        Text(title)
                            .font(.headline)
                    }
                }

                // trailingItems가 있을 때만 표시
                if hasTrailingItems {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        trailingItems
                    }
                }
            }
    }
}

extension View {
    func gimifeedbackNavi<TrailingItems: View>(
        title: String? = nil,
        @ViewBuilder trailingItems: () -> TrailingItems
    ) -> some View {
        self.modifier(CustomNaviModifier(title: title, trailingItems: trailingItems()))
    }

    // trailingItems 생략 가능 버전
    func gimifeedbackNavi(title: String? = nil) -> some View {
        self.modifier(CustomNaviModifier(title: title, trailingItems: EmptyView()))
    }
}
