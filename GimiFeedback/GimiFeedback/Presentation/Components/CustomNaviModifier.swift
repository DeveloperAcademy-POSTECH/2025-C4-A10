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
                ToolbarItemGroup(placement: .topBarTrailing) {
                    trailingItems
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
}
