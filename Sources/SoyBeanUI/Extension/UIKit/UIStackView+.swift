//
//  UIStackView+.swift
//  SoyBean
//
//  Created by 구태호 on 6/16/25.
//

#if os(iOS)
import UIKit


public extension UIStackView {
    func addArrangedSubviews(_ views: UIView...) {
        views.forEach { addArrangedSubview($0) }
    }
    
    func removeSubview(_ view: UIView?) {
        guard let view = view else { return }
        
        removeArrangedSubview(view)
        view.removeFromSuperview()
    }
    
    func removeAllSubviews() {
        arrangedSubviews.forEach { view in
            removeSubview(view)
        }
    }
}

public extension UIStackView {
    convenience init(
        axis: NSLayoutConstraint.Axis,
        spacing: CGFloat = .zero,
        alignment: UIStackView.Alignment = .fill,
        distribution: UIStackView.Distribution = .fill,
        padding: NSDirectionalEdgeInsets? = nil,
        subviews: [UIView] = []
    ) {
        self.init(arrangedSubviews: subviews)
        self.axis = axis
        self.spacing = spacing
        self.alignment = alignment
        self.distribution = distribution
        
        if let padding {
            isLayoutMarginsRelativeArrangement = true
            directionalLayoutMargins = padding
        }
    }
}

#endif
