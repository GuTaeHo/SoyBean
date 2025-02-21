//
//  DecodeUtil.swift
//  SoyBean
//
//  Created by 구태호 on 2/12/25.
//

import Foundation

public class DecodeUtil {
    /// String 형태의 JWT Token 파싱
    /// - Note: JWT Token 은 header, payload, signature 로 구성되어있다. 각각의 정보는 `.` 을 기준으로 구분되며, 실질적인 정보는 두 번째 `payload` 부분에 저장된다
    public static func jwtDecode(jwtToken jwt: String) -> [String: Any] {
        let segments = jwt.components(separatedBy: ".")
        return decodeJWTpayload(segments[1]) ?? [:]
    }
    
    public static func decodeJWTpayload(_ payload: String) -> [String: Any]? {
        guard let bodyData = base64UrlDecode(payload),
              let json = try? JSONSerialization.jsonObject(with: bodyData, options: []), let payload = json as? [String: Any] else {
            return nil
        }
        
        return payload
    }
    
    public static func base64UrlDecode(_ value: String) -> Data? {
        var base64 = value
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        let length = Double(base64.lengthOfBytes(using: String.Encoding.utf8))
        let requiredLength = 4 * ceil(length / 4.0)
        let paddingLength = requiredLength - length
        if paddingLength > 0 {
            let padding = "".padding(toLength: Int(paddingLength), withPad: "=", startingAt: 0)
            base64 = base64 + padding
        }
        return Data(base64Encoded: base64, options: .ignoreUnknownCharacters)
    }
}
