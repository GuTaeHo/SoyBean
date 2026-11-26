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
    /// - Note: 기기의 언어, 12시간제 설정, 달력(불교력 등)에 영향받지 않도록 `en_US_POSIX` locale 과 그레고리력을 사용합니다.
    ///   시간대는 기기 시간대를 따릅니다.
    /// - Warning: 절대로 외부에서 이 DateFormatter 의 속성을 바꾸지 말 것 (사이드 이펙트 발생 및 디버깅 어려워짐)
    static let shared: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
}
