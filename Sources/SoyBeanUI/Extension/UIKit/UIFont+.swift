//
//  UIFont+.swift
//  SoyBean
//
//  Created by 구태호 on 6/16/25.
//



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
