//
//  UIFont+Register.swift
//  SoyBean
//
//  Created by 구태호 on 2/15/25.
//

import UIKit
import SwiftUI

public enum FontType: String, CaseIterable {
    case regular400 = "Pretendard-Regular"
    case medium500 = "Pretendard-Medium"
    case semiBold600 = "Pretendard-SemiBold"
    case bold700 = "Pretendard-Bold"
}

public extension UIFont {
    static func registerFonts() {
        FontType.allCases.forEach { font in
            guard let url = Bundle.module.url(forResource: font.rawValue,
                                              withExtension: "otf") else { return }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }
    
    static func custom(type: FontType, size: CGFloat) -> UIFont {
        return UIFont(name: type.rawValue, size: size) ?? .systemFont(ofSize: size)
    }
}

public extension Font {
    static func custom(_ type: FontType, size: CGFloat) -> Font {
        return .custom(type.rawValue, fixedSize: size)
    }
}
