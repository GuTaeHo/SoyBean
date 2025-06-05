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
    
    /// `JSON` 형태의 포맷으로 변환
    var toPrettyJSON:  String {
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
    
    /**
        날짜 포맷이 적용된 `Date` 형태로 변환
     
        - Parameters:
            - format: 날짜 포맷, 기본값은 "yyyy-MM-dd HH:mm:ss"
            - secondsFromGMT: 표준 GMT 시간으로부터 차이, 숫자가 커질수록 빨라짐, 기본값은 한국 표준시인 **9**
        - Returns: 변환할 수 없는 경우 nil 을 반환
        - Important: **secondsFromGMT** 값이 별도로 지정되지 않았다면, 항상 한국 표준시를 반환
     
     Example
     ```swift
        "2024-10-17 15:42:30".toDate()  //  2024년 10월 17일 15시 42분 30초
        "2024-10-17 15:42:30".toDate("yyyy-MM-dd HH:mm:ss", secondsFromGMT: 0)  //  2024년 10월 17일 06시 42분 30초
     ```
     */
    func toDate(_ format: String = "yyyy-MM-dd HH:mm:ss", secondsFromGMT: Int = 9) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = .init(secondsFromGMT: 9)
        formatter.locale = .current
        return formatter.date(from: self)
    }
}
