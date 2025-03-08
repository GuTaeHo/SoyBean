//
//  View+.swift
//  SoyBean
//
//  Created by 구태호 on 2/30/25.
//

import SwiftUI
import SoyBeanCore

extension View {
    
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


#if os(iOS)
import UIKit


public extension UIView {
    private var ANIMATION_TARGET_INTERVAL: CGFloat {
        get {
            return 0.3
        }
    }
    
    /// 뷰 숨김
    /// - Parameter animated: 애니메이션 사용 여부 (기본값: false)
    func hidden(animated: Bool = false) {
        if self.isHidden {
            return
        }
        
        if animated {
            UIView.animate(withDuration: self.ANIMATION_TARGET_INTERVAL, animations: {
                self.isHidden = true
                self.alpha = 0
            })
        } else {
            self.isHidden = true
            self.alpha = 0
        }
    }
    
    /// 뷰 표시
    /// - Parameter animated: 애니메이션 사용 여부 (기본값: false)
    func display(animated: Bool = false) {
        if animated {
            UIView.animate(withDuration: self.ANIMATION_TARGET_INTERVAL) {
                self.isHidden = false
                self.alpha = 1
                self.superview?.layoutIfNeeded()
            }
        } else {
            self.isHidden = false
            self.alpha = 1
        }
    }
    
    /// 뷰 흔들기
    /// - Parameters:
    ///     - duration: 지속 시간 (기본값: 0.05)
    ///     - repeatCount: 반복 횟수 (기본값: 2)
    ///     - from: 시작 지점 (기본값: 5)
    ///     - to: 끝 지점 (기본값: 5)
    func shake(duration: CGFloat = 0.05, repeatCount: Float = 2, from: CGFloat = 5, to: CGFloat = 5) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = duration
        animation.repeatCount = repeatCount
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - from, y: self.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + to, y: self.center.y))
        self.layer.add(animation, forKey: "position")
        
        HapticManager.shared.start(.notification(.error))
    }
}

public extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }
}

public extension UIView {
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        
        set {
            layer.cornerRadius = newValue
            clipsToBounds = true
        }
    }
}

#endif
