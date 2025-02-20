//
//  DateFormatter+.swift
//  SoyBean
//
//  Created by 구태호 on 2/12/25.
//


import Foundation


public extension DateFormatter {
    static let shared: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
}
