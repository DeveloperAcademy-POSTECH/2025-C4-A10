//
//  View+Extension.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/25/25.
//

import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil, from: nil, for: nil
        )
    }
}
