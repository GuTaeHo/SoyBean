//
//  Color+.swift
//  SoyBean
//
//  Created by 구태호 on 2/19/25.
//

import SwiftUI
#if os(iOS)
import UIKit
#endif

public extension Color {
    /// RGB 로 색상 초기화
    init(red: Double, green: Double, blue: Double, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: red.clamped(to: 0.0...1.0),
            green: green.clamped(to: 0.0...1.0),
            blue: blue.clamped(to: 0.0...1.0),
            opacity: alpha.clamped(to: 0.0...1.0)
        )
    }
    
    /// HEX 문자열로 색상 초기화
    /// - Parameters:
    ///   - hex: HEX 문자열 (ex "#FF5733", "FF5733", or "FFF")
    ///   - alpha: 0.0 ~ 1.0 사이의 알파 값, 없다면 1.0
    init(hex: String, alpha: Double = 1.0) {
        let sanitizedHex = hex
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        
        var rgbValue: UInt64 = 0
        Scanner(string: sanitizedHex).scanHexInt64(&rgbValue)
        
        let length = sanitizedHex.count
        let red, green, blue: Double
        
        switch length {
        case 6: // HEX format: RRGGBB
            red = Double((rgbValue >> 16) & 0xFF) / 255.0
            green = Double((rgbValue >> 8) & 0xFF) / 255.0
            blue = Double(rgbValue & 0xFF) / 255.0
        case 3: // HEX format: RGB (shorthand)
            red = Double((rgbValue >> 8) & 0xF) / 15.0
            green = Double((rgbValue >> 4) & 0xF) / 15.0
            blue = Double(rgbValue & 0xF) / 15.0
        default:
            // Invalid HEX format
            red = 0
            green = 0
            blue = 0
        }
        
        self.init(
            .sRGB,
            red: red.clamped(to: 0.0...1.0),
            green: green.clamped(to: 0.0...1.0),
            blue: blue.clamped(to: 0.0...1.0),
            opacity: alpha.clamped(to: 0.0...1.0)
        )
    }
}



extension Color: ColorConvertible {
    /// ColorConvertible -> Color 로 변환
    public var toSwiftUIColor: Color {
        return self
    }
#if os(iOS)
    /// SwiftUI Color -> UIColor 로 변환
    public var toUIColor: UIColor? {
        UIColor(self)
    }
#endif
}

public extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
