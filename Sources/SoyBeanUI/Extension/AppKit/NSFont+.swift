//
//  NSFont+.swift
//  SoyBean
//
//  Created by 구태호 on 6/16/25.
//



#if os(macOS)
import AppKit

public extension NSFont {
    static func custom(type: FontType, size: CGFloat) -> NSFont {
        return NSFont(name: type.rawValue, size: size) ?? .systemFont(ofSize: size)
    }

    /// 시스템에 등록된 폰트 명을 출력합니다.
    static func fontNames() -> [String] {
        let fontManager = NSFontManager.shared
        return fontManager.availableFontFamilies
            .flatMap { familyName in
                (fontManager.availableMembers(ofFontFamily: familyName) ?? [])
                    .compactMap { $0.first as? String }
            }
    }
}
#endif
