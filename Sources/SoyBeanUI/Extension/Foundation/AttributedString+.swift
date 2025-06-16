//
//  AttributedString+.swift
//  SoyBean
//
//  Created by 구태호 on 2/19/25.
//


import SwiftUI



public extension AttributedString {
#if os(iOS)
    /// 속성이 지정된 문자열을 반환합니다.
    static func styledText(_ text: String,
                           fontType: FontType,
                           fontSize: CGFloat,
                           fontColor: UIColor = .white,
                           textAlignment: NSTextAlignment = .left) -> AttributedString {
        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = textAlignment
        
        let attr: [NSAttributedString.Key : Any] = [
            .font: UIFont.custom(type: fontType, size: fontSize),
            .foregroundColor: fontColor,
            .paragraphStyle: paragraphStyle
        ]
        
        let attrStr = NSAttributedString(string: text, attributes: attr)
        
        return AttributedString(attrStr)
    }
#elseif os(macOS)
    /// 속성이 지정된 문자열을 반환합니다.
    static func styledText(_ text: String,
                           fontType: FontType,
                           fontSize: CGFloat,
                           fontColor: NSColor = .white,
                           textAlignment: NSTextAlignment = .left) -> AttributedString {
        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = textAlignment
        
        let attr: [NSAttributedString.Key : Any] = [
            .font: NSFont.custom(type: fontType, size: fontSize),
            .foregroundColor: fontColor,
            .paragraphStyle: paragraphStyle
        ]
        
        let attrStr = NSAttributedString(string: text, attributes: attr)
        
        return AttributedString(attrStr)
    }
#endif
    
    var toMutable: NSMutableAttributedString {
        return NSMutableAttributedString(self)
    }
}
