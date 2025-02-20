//
//  AttributedString+.swift
//  SoyBean
//
//  Created by 구태호 on 2/19/25.
//


import SwiftUI

#if os(iOS)
import UIKit


public extension AttributedString {
    /// 속성이 지정된 문자열을 반환합니다.
    static func styledText(_ text: String,
                           fontType: Font.FontType,
                           fontSize: CGFloat,
                           fontColor: UIColor = .white,
                           textAlignment: NSTextAlignment = .left) -> AttributedString {
        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = textAlignment
        
        let attr: [NSAttributedString.Key : Any] = [
            .font: Font.custom(fontType, size: fontSize).toUIFont,
            .foregroundColor: fontColor,
            .paragraphStyle: paragraphStyle
        ]
        
        let attrStr = NSAttributedString(string: text, attributes: attr)
        
        return AttributedString(attrStr)
    }
    
    var toMutable: NSMutableAttributedString {
        return NSMutableAttributedString(self)
    }
}
#endif
