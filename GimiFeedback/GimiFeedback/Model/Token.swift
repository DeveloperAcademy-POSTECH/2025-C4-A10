//
//  Token.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/17/25.
//

import Foundation

struct Token: Codable, Hashable {
    let id: String
    let fcmToken: String
    let badgeCount: Int
    
    init(
        userID: String = FirebaseAuthManager.currentUserID ?? "",
        fcmToken: String,
        badgeCount: Int
    ) {
        self.id = userID
        self.fcmToken = fcmToken
        self.badgeCount = badgeCount
    }
}

extension Token: EntityRepresentable {
    var entityName: CollectionType { .token }
    var documentID: String { id }
}
