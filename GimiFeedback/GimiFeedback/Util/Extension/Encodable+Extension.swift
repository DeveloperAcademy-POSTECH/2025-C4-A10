//
//  Encodable.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/10/25.
//

import Foundation

extension Encodable {
    var asDictionary: [String: Any]? {
        guard let object = try? JSONEncoder().encode(self),
              let dictionary = try? JSONSerialization.jsonObject(with: object, options: [])
                as? [String: Any] else {
            return nil
        }
        
        return dictionary
    }
}
