//
//  Path.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/9/25.
//

import Foundation

class NavigaitionRouter: ObservableObject {
    @Published var destinations: [NavigationDestination]
    
    init(destinations: [NavigationDestination] = []) {
        self.destinations = destinations
    }
    
    func push(to view: NavigationDestination) {
        destinations.append(view)
    }
    
    func pop() {
        _ = destinations.popLast()
    }
    
    func popToRootView() {
        destinations = []
    }
}
