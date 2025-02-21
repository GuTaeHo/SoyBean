//
//  Font+.swift
//  SoyBean
//
//  Created by 구태호 on 2/15/25.
//

import SwiftUI

public enum FontType: String, CaseIterable {
    case regular400 = "Pretendard-Regular"
    case medium500 = "Pretendard-Medium"
    case semiBold600 = "Pretendard-SemiBold"
    case bold700 = "Pretendard-Bold"
}

#if os(iOS)
import UIKit

public extension UIFont {
    static func custom(type: FontType, size: CGFloat) -> UIFont {
        return UIFont(name: type.rawValue, size: size) ?? .systemFont(ofSize: size)
    }
    
    /// 시스템에 등록된 폰트 명을 출력합니다.
    static func fontNames() -> [String] {
        UIFont.familyNames
            .map { $0 }
            .flatMap {
                UIFont.fontNames(forFamilyName: $0).compactMap { fontName in
                    fontName
                }
            }
    }
}

#endif

public extension Font {
    static func custom(_ type: FontType, size: CGFloat) -> Font {
        return .custom(type.rawValue, fixedSize: size)
    }
    
    /// 폰트를 등록합니다.
    /// - Returns: 등록된 폰트 이름 배열 반환
    /// - Important: 앱 진입점에서 호출
    static func registerFonts() -> [String] {
        FontType.allCases.compactMap { font in
            guard let url = Bundle.module.url(forResource: font.rawValue,
                                              withExtension: "otf") else { return nil }
            if CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil) {
                return font.rawValue
            } else {
                return nil
            }
        }
    }
}
