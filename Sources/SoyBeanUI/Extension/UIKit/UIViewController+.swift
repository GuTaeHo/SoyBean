//
//  UIViewController+.swift
//  SoyBean
//
//  Created by 구태호 on 6/16/25.
//

#if os(iOS)
import UIKit

extension UIViewController {
    /// 자식 UIViewController 를 특정 컨테이너 뷰에 추가합니다
    /// - Parameters:
    ///     - childs: 추가될 자식 UIViewController
    ///     - containerView: 자식 UIViewController 가 추가될 컨테이너 UIView
    /// - Important: 자식 UIViewController 는 containerView 와 동일한 제약조건으로 설정됨
    func addChilds(_ childs: UIViewController..., to containerView: UIView) {
        childs.forEach { child in
            addChild(child)
            containerView.addSubviews(child.view)
            child.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                child.view.topAnchor.constraint(equalTo: containerView.topAnchor),
                child.view.leftAnchor.constraint(equalTo: containerView.leftAnchor),
                child.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
                child.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
            ])
        }
    }
    
    /// 자식 UIViewController 를 컨테이너 뷰에서 제거합니다
    func removeChilds(_ childs: UIViewController...) {
        childs
            .filter { child in
                child == self
            }.forEach { child in
                child.willMove(toParent: nil)
                child.view.removeFromSuperview()
                child.removeFromParent()
            }
    }
}
#endif
