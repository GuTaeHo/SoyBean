//
//  ShakeEffect.swift
//  SoyBean
//
//  Created by 구태호 on 3/8/25.
//

import SwiftUI


struct ShakeEffect: GeometryEffect {
    var amount: CGFloat

    var animatableData: CGFloat {
        get { amount }
        set { amount = newValue }
    }
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: amount * sin(amount * .pi),
                                              y: 0))
    }
}
