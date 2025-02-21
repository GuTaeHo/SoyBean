//
//  Font+.swift
//  SoyBean
//
//  Created by 구태호 on 2/15/25.
//

import SwiftUI

public enum FontType: String, CaseIterable {
    /// 400, Regular, Pretendard
    case pretendardRegular = "Pretendard-Regular"
    /// 500, Medium, Pretendard
    case pretendardMedium = "Pretendard-Medium"
    /// 600, SemiBold, Pretendard
    case pretendardSemiBold = "Pretendard-SemiBold"
    /// 700, Bold, Pretendard
    case pretendardBold = "Pretendard-Bold"
    /// 100, Thin, IBMPlexSansKR
    case IBMPlexThin = "IBMPlexSansKR-Thin"
    /// 300, Light, IBMPlexSansKR
    case IBMPlexLight = "IBMPlexSansKR-Light"
    /// 400, Regular, IBMPlexSansKR
    case IBMPlexRegular = "IBMPlexSansKR-Regular"
    /// 500, Medium, IBMPlexSansKR
    case IBMPlexMedium = "IBMPlexSansKR-Medium"
    /// 600, SemiBold, IBMPlexSansKR
    case IBMPlexSemiBold = "IBMPlexSansKR-SemiBold"
    /// 700, Bold, IBMPlexSansKR
    case IBMPlexBold = "IBMPlexSansKR-Bold"
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
