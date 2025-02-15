//
//  UIView+Font.swift
//  SoyBean
//
//  Created by 구태호 on 2/15/25.
//

import UIKit
import SwiftUI


public extension UIView {
    
}


public extension View {
    /// Note: Xcode 프리뷰에서 커스텀 폰트를 표시하기 위해 호출할 것, 앱에서는 필요하지 않음
    func loadCustomFonts() -> some View {
        Font.registerFonts()
        return self
    }
}
