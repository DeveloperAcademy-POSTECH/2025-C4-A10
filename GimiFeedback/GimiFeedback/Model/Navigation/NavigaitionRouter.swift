//
//  Path.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/9/25.
//

import Foundation

class NavigaitionRouter<T: Hashable>: ObservableObject {
    @Published var destinations: [T]
    
    init(destinations: [T] = []) {
        self.destinations = destinations
    }
    
    func push(to view: T) {
        destinations.append(view)
    }
    
    func pop() {
        _ = destinations.popLast()
    }
    
    func popToRootView() {
        destinations = []
    }
}
