//
//  CALayer+.swift
//  SoyBean
//
//  Created by 구태호 on 2/21/25.
//

import SwiftUI


public extension CALayer {
    /// 일치하는 레이어가 있을 경우 true 를 반환합니다.
    func isExistLayer(name: String) -> Bool {
        if let _ = sublayers?.first(where: { $0.name == name }) {
            return true
        } else {
            return false
        }
    }
    
    /// 일치하는 레이어를 제거합니다.
    func removeLayer(name: String) {
        if let layer = sublayers?.first(where: { $0.name == name }) {
            layer.removeFromSuperlayer()
            layer.removeAllAnimations()
        }
    }
}
