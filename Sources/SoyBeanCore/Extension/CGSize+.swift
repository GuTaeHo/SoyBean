//
//  CGSize+.swift
//  SoyBean
//
//  Created by 구태호 on 3/15/25.
//

import Foundation


public extension CGSize {
    static func + (lhs: Self, rhs: Self) -> Self {
        CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
}
