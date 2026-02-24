//
//  TextViewModifier.swift
//  SoyBean
//
//  Created by 구태호 on 5/12/25.
//

import SwiftUI


/// 텍스트 폰트 스타일, 폰트 색상, 정렬을 지정하는 모디파이어.
struct TextViewModifier: ViewModifier {
    var font: Font
    var color: Color
    var alignment: TextAlignment
    
    func body(content: Content) -> some View {
        content
            .font(font)
            .foregroundStyle(color)
            .multilineTextAlignment(alignment)
    }
}
