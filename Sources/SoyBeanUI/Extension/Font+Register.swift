//
//  UIFont+Register.swift
//  SoyBean
//
//  Created by 구태호 on 2/15/25.
//

import UIKit
import SwiftUI

private enum CustomFonts: String, CaseIterable {
    case pretendardBold = "Pretendard-Bold"
    case pretendardSemiBold = "Pretendard-SemiBold"
    case pretendardMedium = "Pretendard-Medium"
    case pretendardRegular = "Pretendard-Regular"
}


public extension UIFont {
    static func registerFonts() {
        CustomFonts.allCases.forEach { font in
            guard let url = Bundle.main.url(forResource: font.rawValue,
                                              withExtension: "ttf") else { return }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }
}

public extension Font {
    static func registerFonts() {
        CustomFonts.allCases.forEach { font in
            guard let url = Bundle.module.url(forResource: font.rawValue,
                                              withExtension: "ttf") else { return }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }
}
