//
//  FormatUtil.swift
//  SoyBean
//
//  Created by 구태호 on 2/12/25.
//

import Foundation
import SoyBeanCore


public class FormatUtil {
    public enum DateFormat {
        case MM_Dot_dd
        case yy_Dot_MM_Dot_dd
        case custom(String)
        
        var toFormat: String {
            switch self {
            case .MM_Dot_dd:
                return "MM.dd"
            case .yy_Dot_MM_Dot_dd:
                return "yy.MM.dd"
            case .custom(let format):
                return format
            }
        }
    }
    
    /// `format` 형식에 맞춰 String 날짜를 반환합니다
    /// - Parameters:
    ///   - date: 변환되기 전 `"yyyy-MM-dd HH:mm:ss"` 형태의 날짜
    ///   - format: 변환될 포맷
    /// - Returns: `format` 에 맞게 변환된 `String` 형태의 날짜
    /// - Important: 이 메소드는 호출마다 `DateFormatter()` 를 새로 생성합니다.
    public static func formatDate(_ date: String, to format: DateFormat) throws -> String {
        let baseFormatter = DateFormatter.shared
        
        if let date = baseFormatter.date(from: date) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = format.toFormat
            return dateFormatter.string(from: date)
        }
        
        throw SoyBeanError.dateFormattingError(format: format.toFormat)
    }
}
