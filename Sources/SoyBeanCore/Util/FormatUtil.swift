//
//  FormatUtil.swift
//  SoyBean
//
//  Created by 구태호 on 2/12/25.
//

import Foundation


public class FormatUtil {
    public enum DateFormat: String {
        case MM_Dot_dd = "MM.dd"
    }
    
    static func formatDate(_ date: String, to toFormat: DateFormat) throws -> String {
        let dateFormatter = DateFormatter.shared
        
        if let date = dateFormatter.date(from: date) {
            dateFormatter.dateFormat = toFormat.rawValue
            return dateFormatter.string(from: date)
        }
        
        throw DomainError.dateFormattingError(format: toFormat.rawValue)
    }
}
