//
//  Date+.swift
//  SoyBean
//
//  Created by 구태호 on 6/5/25.
//

import Foundation


public extension Date {
    enum CompareType {
        case late
        case same
        case early
    }
    
    
    /**
     두 날짜의 시간 차를 초단위로 반환
     
     - Parameter comparison: 비교 대상이 되는 날짜
     
     - Note: **receiver** 가 **comparison** 보다 이르다면 음수값을 반환
     
     Example
     ```swift
     // 예시
     // receiver 의 시각 2024-10-17 16:01:20
     // comparison 의 시각 2024-10-17 16:03:40
     
     date1.timeDifferenceToSecond(date2) // 140
     ```
     */
    func timeDifferenceToSecond(_ comparison: Date) -> Int {
        return Int(timeIntervalSince(comparison))
    }
    
    /**
     두 날짜 문자열을 지정된 포맷으로 `Date`로 변환한 후 비교하여,
     기준 날짜가 더 빠른지, 늦은지 또는 같은지를 출력
     
     - Parameters:
     - baseDate: 기준이 되는 날짜 문자열
     - targetDate: 비교 대상이 되는 날짜 문자열
     - format: 날짜 문자열의 포맷. 기본값은 "yyyy-MM-dd HH:mm:ss"
     
     - Note: 날짜 형식이 `format`과 맞지 않으면 변환에 실패할 수 있음.
     
     Example
     ```swift
     compareDates("2025-06-01 14:00:00", targetDate: "2025-06-01 16:00:00")
     ```
     */
    func compareDates(_ baseDate: String,
                      targetDate: String,
                      format: String = "yyyy-MM-dd HH:mm:ss") -> CompareType? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard
            let date1 = dateFormatter.date(from: baseDate),
            let date2 = dateFormatter.date(from: targetDate)
        else {
            return nil
        }
        
        if date1 < date2 {
            return .early
        } else if date1 > date2 {
            return .late
        } else {
            return .same
        }
    }
    
    /**
     현재 날짜로 부터 남은 일 수 반환
     
     - Parameters:
         - date: 기준이 되는 날짜
         - format: 날짜 문자열의 포맷. 기본값은 "yyyy-MM-dd HH:mm:ss"
     - Returns: 0 또는 정수, 날짜 형식이 `format`과 맞지 않으면 nil 반환
     */
    func remainingDays(_ date: String, format: String = "yyyy-MM-dd HH:mm:ss") -> Int? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(abbreviation: "KST")
        
        let expDateTypeDate = dateFormatter.date(from: date)
        
        guard
            let expDateTypeDate = expDateTypeDate
        else {
            return nil
        }
        
        guard
            let reminingDay = Calendar.current.dateComponents([.day], from: Date(), to: expDateTypeDate).day
        else {
            return nil
        }
        
        if reminingDay <= 0 {
            return 0
        } else {
            return reminingDay
        }
    }
}
