//
//  View+.swift
//  SoyBean
//
//  Created by 구태호 on 2/30/25.
//

import SwiftUI
import SoyBeanCore

public extension View {
    
    /**
     뷰 흔들기
     
     - Parameters:
     - amount: 좌, 우 흔들림 정도
     
     ```swift
     // 사용방법
     
     @State var isShake: Bool = false
     
     Button("Hello")
     .shake(amount: isShake ? 20 : 0)
     ```
     */
    func shake(amount: Double = 10.0) -> some View {
        self.modifier(ShakeEffect(amount: CGFloat(amount)))
    }
}


// MARK: - View Modifier
public extension View {
    
    /// 텍스트 스타일 지정
    /// - Note: 먼저 Font.registerFonts() 를 호출해, 폰트 등록
    func textStyle(fontType: FontType,
                   fontSize: CGFloat,
                   color: Color) -> some View {
        modifier(TextViewModifier(font: .custom(fontType,
                                                size: fontSize),
                                  color: color))
    }
}
