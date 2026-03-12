//
//  UIBarButtonItem+.swift
//  SoyBean
//
//  Created by 구태호 on 3/12/26.
//

import UIKit

public extension UIBarButtonItem {
    typealias UIBarButtonItemTargetClosure = (UIBarButtonItem) -> Void

    private class UIBarButtonItemClosureWrapper: NSObject {
        let closure: UIBarButtonItemTargetClosure
        init(_ closure: @escaping UIBarButtonItemTargetClosure) {
            self.closure = closure
        }
    }

    private enum AssociatedKeys {
        static var targetClosure = "targetClosure"
        static var actionHandler = "actionHandler"
    }

    private var targetClosure: UIBarButtonItemTargetClosure? {
        get {
            guard let closureWrapper = objc_getAssociatedObject(self,
                                                                &AssociatedKeys
                                                                    .targetClosure) as? UIBarButtonItemClosureWrapper
            else { return nil }
            return closureWrapper.closure
        }
        set(newValue) {
            guard let newValue = newValue else { return }
            objc_setAssociatedObject(self,
                                     &AssociatedKeys.targetClosure,
                                     UIBarButtonItemClosureWrapper(newValue),
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    @objc func closureAction() {
        guard let targetClosure = targetClosure else { return }
        targetClosure(self)
    }

    convenience init(title: String?, style: UIBarButtonItem.Style, closure: @escaping UIBarButtonItemTargetClosure) {
        self.init(title: title, style: style, target: nil, action: nil)
        targetClosure = closure
        action = #selector(UIBarButtonItem.closureAction)
    }

    convenience init(image: UIImage, style: UIBarButtonItem.Style, closure: @escaping UIBarButtonItemTargetClosure) {
        self.init(image: image, style: style, target: nil, action: nil)
        targetClosure = closure
        action = #selector(UIBarButtonItem.closureAction)
    }
}
