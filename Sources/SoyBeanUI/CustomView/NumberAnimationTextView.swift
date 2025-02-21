//
//  NumberAnimationTextView.swift
//  SoyBean
//
//  Created by 구태호 on 2/21/25.
//

import SwiftUI


/// 애니메이션이 적용된 TextView
/// - Note: iOS 16 이상부터 애니메이션 적용
public struct NumberAnimationTextView: View {
    @Binding var number: Int
    
    public init(number: Int) {
        self._number = .constant(number)
    }
    
    public var body: some View {
        if #available(iOS 16.0, macOS 13.0, *) {
            numberText
                .contentTransition(.numericText())
        } else {
            numberText
        }
    }
    
    @ViewBuilder
    var numberText: some View {
        Text("\(number)")
            .font(.custom(.bold700, size: 30))
    }
}

#Preview {
    NumberAnimationTextView(number: 1000)
}
