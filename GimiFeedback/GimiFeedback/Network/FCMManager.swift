//
//  FCMManager.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/17/25.
//

import Foundation
import FirebaseFunctions
import FirebaseMessaging

final class FCMManager {
    static let shared = FCMManager()
    private let functions = Functions.functions()
    
    private init() {}
    
    func getTokenString() async throws -> String {
        let token = try await Messaging.messaging().token()
        return token
    }
    
    /// 푸시 알림 보내기
    /// - Parameters:
    ///   - userId: 수신자 UID (Firestore 기준)
    ///   - sendUserName: 보낸 사람 이름
    ///   - messageContent: 메시지 내용
    func sendNotification(
        to userId: String,
        from sendUserName: String,
        title: String = "Gimi Feedback",
        messageContent: String? = nil
    ) {
        let data: [String: Any] = [
            "targetUid": userId,
            "title": title,
            "body": "\(sendUserName)님이 피드백을 보냈습니다!",
        ]
        
        functions.httpsCallable("sendNotification").call(data) { result, error in
            if let error = error as NSError? {
                print("푸시 전송 실패: \(error.localizedDescription)")
                return
            }
            
            if let res = result?.data as? [String: Any], let success = res["success"] as? Bool, success {
                print("푸시 전송 성공")
            } else {
                print("응답 형식 오류 또는 실패: \(String(describing: result?.data))")
            }
        }
    }
}
