//
//  ViewModelable.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/8/25.
//

import Foundation

@MainActor
protocol ViewModelable: ObservableObject {
    associatedtype Action
    
    func send(_ action: Action)
}
