//
//  User.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/17/25.
//

import Foundation

struct User: Codable, Hashable {
    let id: String
    let nickName: String
    let fcmToken: String
    let badgeCount: Int
    
    init(
        userID: String,
        nickName: String,
        fcmToken: String,
        badgeCount: Int
    ) {
        self.id = userID
        self.nickName = nickName
        self.fcmToken = fcmToken
        self.badgeCount = badgeCount
    }
}

extension User: EntityRepresentable {
    var entityName: CollectionType { .user }
    var documentID: String { id }
}
