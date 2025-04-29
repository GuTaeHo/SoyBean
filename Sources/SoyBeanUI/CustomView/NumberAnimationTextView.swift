//
//  NumberAnimationTextView.swift
//  SoyBean
//
//  Created by 구태호 on 2/21/25.
//

import SwiftUI


/// 애니메이션이 적용된 TextView
/// - Note: iOS 16, macOS 13.0, watchOS 9.0 이상부터 애니메이션 적용
public struct NumberAnimationTextView: View {
    @Binding var number: Int
    @Binding var font: Font
    
    public init(font: Font, number: Int) {
        self._font = .constant(font)
        self._number = .constant(number)
    }
    
    public var body: some View {
        if #available(iOS 16.0, macOS 13.0, watchOS 9.0, *) {
            numberText
                .contentTransition(.numericText())
        } else {
            numberText
        }
    }
    
    @ViewBuilder
    var numberText: some View {
        Text("\(number)")
            .font(font)
    }
}

#Preview {
    NumberAnimationTextView(font: .custom(.IBMPlexThin, size: 30),
                            number: 1000)
}
