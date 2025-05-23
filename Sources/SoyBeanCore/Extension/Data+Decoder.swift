//
//  Data+Decoder.swift
//  SoyBean
//
//  Created by 구태호 on 5/23/25.
//

import Foundation


public extension Data {
    /// Data 를 Dictionary 형태로 변환
    /// - Important: Data 는 반드시 **JSON 포맷** 을 준수해야함
    var toJSONDictionary: [String : Any]? {
        guard
            let jsonObject = try? JSONSerialization.jsonObject(with: self, options: []),
            let dictionary = jsonObject as? [String: Any]
        else {
            return nil
        }
        
        return dictionary
    }
}
