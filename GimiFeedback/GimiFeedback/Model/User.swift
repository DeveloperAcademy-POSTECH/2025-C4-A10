//
//  User.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/17/25.
//

import Foundation

struct User: Codable, Hashable {
    let id: String
    let fcmToken: String
    let badgeCount: Int
    
    init(
        userID: String,
        fcmToken: String,
        badgeCount: Int
    ) {
        self.id = userID
        self.fcmToken = fcmToken
        self.badgeCount = badgeCount
    }
}

extension User: EntityRepresentable {
    var entityName: CollectionType { .user }
    var documentID: String { id }
}
