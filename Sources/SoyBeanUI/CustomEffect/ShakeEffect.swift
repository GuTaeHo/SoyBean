//
//  ShakeEffect.swift
//  SoyBean
//
//  Created by 구태호 on 3/8/25.
//

import SwiftUI


struct ShakeEffect: GeometryEffect {
    let amount: CGFloat
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: amount * sin(.pi),
                                              y: 0))
    }
}
