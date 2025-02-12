//
//  EdgeInset+Init.swift
//  SoyBean
//
//  Created by 구태호 on 2/12/25.
//

import SwiftUI

public extension EdgeInsets {
    init(all: CGFloat) {
        self.init(top: all, leading: all, bottom: all, trailing: all)
    }
    
    init(horizontal: CGFloat) {
        self.init(top: 0, leading: horizontal, bottom: 0, trailing: horizontal)
    }
    
    init(vertical: CGFloat) {
        self.init(top: vertical, leading: 0, bottom: vertical, trailing: 0)
    }
    
    init(horizontal: CGFloat, vertical: CGFloat) {
        self.init(top: vertical, leading: horizontal, bottom: vertical, trailing: horizontal)
    }
}

public extension NSDirectionalEdgeInsets {
    init(all: CGFloat) {
        self.init(top: all, leading: all, bottom: all, trailing: all)
    }
    
    init(horizontal: CGFloat) {
        self.init(top: 0, leading: horizontal, bottom: 0, trailing: horizontal)
    }
    
    init(vertical: CGFloat) {
        self.init(top: vertical, leading: 0, bottom: vertical, trailing: 0)
    }
    
    init(horizontal: CGFloat, vertical: CGFloat) {
        self.init(top: vertical, leading: horizontal, bottom: vertical, trailing: horizontal)
    }
}
