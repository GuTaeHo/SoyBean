//
//  Optional+String.swift
//  SoyBean
//
//  Created by 구태호 on 2/12/25.
//


import Foundation


public extension Optional where Wrapped == String {
    /// nil 일 경우 빈 문자열("") 반환
    var toEmptyIfOptional: String {
        switch self {
        case .some(let wrapped):
            return wrapped
            
        case .none:
            return ""
        }
    }
}
