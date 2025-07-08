//
//  ViewModelable.swift
//  A10
//
//  Created by 김민석 on 7/8/25.
//

import Foundation

protocol ViewModelable: ObservableObject {
    associatedtype Action
    
    func send(_ action: Action)
}
