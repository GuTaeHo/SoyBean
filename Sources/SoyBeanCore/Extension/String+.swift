//
//  String+.swift
//  SoyBean
//
//  Created by 구태호 on 3/6/25.
//


public extension String {
    /// 공백일 경우 nil 반환
    var toOptionalIfEmpty: String? {
        self.isEmpty ? nil : self
    }
}
