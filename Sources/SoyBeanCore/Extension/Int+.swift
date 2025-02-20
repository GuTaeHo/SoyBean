//
//  Int+.swift
//  SoyBean
//
//  Created by 구태호 on 2/20/25.
//

import Foundation


public extension Int {
    var toString: String { String(self) }
    
    var toCGFloat: CGFloat { CGFloat(self) }
    
    var toDouble: Double { Double(self) }
    
    /// - Returns: 1234567 -> "1,234,567"
    var toDecimalString: String {
        let fomatter = NumberFormatter()
        fomatter.numberStyle = .decimal
        return fomatter.string(from: NSNumber(value: self))!
    }
}
