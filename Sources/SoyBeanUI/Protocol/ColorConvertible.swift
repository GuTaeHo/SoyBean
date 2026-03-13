//
//  ColorConvertible.swift
//  SoyBean
//
//  Created by 구태호 on 3/13/26.
//

import SwiftUI

/// UIColor를 SwiftUI Color 로 변환할 수 있도록 하는 프로토콜.
public protocol ColorConvertible {
    var toSwiftUIColor: Color { get }
}
