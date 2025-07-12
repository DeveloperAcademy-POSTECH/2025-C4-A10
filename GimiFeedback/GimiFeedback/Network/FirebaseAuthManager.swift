//
//  FirebaseAuthManager.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/12/25.
//

import FirebaseAuth

final class FirebaseAuthManager {
    
    static let shared = FirebaseAuthManager()
    
    private init() {}
    
    func emailAuthSignUp(email: String, password: String) async throws {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        
        print(result)
    }
}
