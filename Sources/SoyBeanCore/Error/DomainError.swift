//
//  DomainError.swift
//  SoyBean
//
//  Created by 구태호 on 2/12/25.
//

import Foundation

public enum DomainError: LocalizedError {
    case message(String)
    case invalidURL
    case externalAppOpenError
    case dateFormattingError(format: String)
    
    
    public var errorDescription: String? {
        switch self {
        case .message(let message):
            return message
        case .invalidURL:
            return "잘못된 URL 형식입니다"
        case .externalAppOpenError:
            return "앱을 열 수 없습니다"
        case .dateFormattingError(let format):
            return "날짜 포맷 변환 에러 (포맷: \(format))"
        }
    }
}
