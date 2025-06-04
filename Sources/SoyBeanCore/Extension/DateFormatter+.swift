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
    /// - Warning: 절때로 외부에서 이 DateFormatter 의 속성을 바꾸지 말 것 (사이드 이펙트 발생 및 디버깅 어려워짐)
    static let shared: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
}
