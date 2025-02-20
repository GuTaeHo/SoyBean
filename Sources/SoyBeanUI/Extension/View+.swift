//
//  View+.swift
//  SoyBean
//
//  Created by 구태호 on 2/30/25.
//

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
