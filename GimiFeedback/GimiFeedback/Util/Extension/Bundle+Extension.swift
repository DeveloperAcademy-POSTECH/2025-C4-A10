//
//  Bundle+Extension.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/12/25.
//

import Foundation

extension Bundle {
    
    static var identifier: String {
        Bundle.main.bundleIdentifier ?? ""
    }
    
    static var kakaoNativeAppKey: String {
        Bundle.main.infoDictionary?["KAKAO_NATIVE_APP_KEY"] as? String ?? ""
    }

}
