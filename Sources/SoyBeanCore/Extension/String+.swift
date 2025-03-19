//
//  String+.swift
//  SoyBean
//
//  Created by 구태호 on 3/6/25.
//

import Foundation


public extension String {
    /// 공백일 경우 nil 반환
    var toOptionalIfEmpty: String? {
        self.isEmpty ? nil : self
    }
    
    /// `JSON` 형태의 포맷으로 변환해서 반환
    func toPrettyJSON() -> String {
        if let data = self.data(using: .utf8) {
            do {
                let jsonDic = try JSONSerialization.jsonObject(with: data, options: [])
                let prettyData = try JSONSerialization.data(withJSONObject: jsonDic, options: .prettyPrinted)
                
                return String(data: prettyData, encoding: .utf8) ?? ""
            } catch {
                return error.localizedDescription
            }
        }
        return ""
    }
}
