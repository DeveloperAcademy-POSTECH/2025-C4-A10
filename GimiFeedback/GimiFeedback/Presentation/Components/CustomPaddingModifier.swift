//
//  CustomPaddingModifier.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/25/25.
//

import SwiftUI

struct CustomPaddingModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .padding(.horizontal, 4)
    }
}

extension View {
    func customPadding() -> some View {
        self.modifier(CustomPaddingModifier())
    }
}
