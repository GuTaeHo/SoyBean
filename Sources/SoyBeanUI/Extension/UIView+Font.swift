//
//  UIView+Font.swift
//  SoyBean
//
//  Created by 구태호 on 2/15/25.
//

#if os(iOS)
import UIKit
import SwiftUI


public extension UIView {
    
}


public extension View {
    /// 프리뷰를 위한 커스텀 폰트를 로딩합니다
    /// Note: 앱에서는 호출 필요 X
    func loadCustomFontsForXcodePreviews() -> some View {
        _ = Font.registerFonts()
        return self
    }
}

#elseif os(macOS)
#endif
