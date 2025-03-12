//
//  DateFormatter+.swift
//  SoyBean
//
//  Created by 구태호 on 2/12/25.
//


import Foundation


public extension DateFormatter {
    /// 공통 포맷터 반환
    /// - Note: 포맷: `yyyy-MM-dd HH:mm:ss`
    static let shared: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
}
