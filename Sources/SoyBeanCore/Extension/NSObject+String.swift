//
//  NSObject+String.swift
//  Soybean
//
//  Created by 구태호 on 12/26/24.
//

import Foundation


public extension NSObject {
    var className: String {
        return String(describing: self)
    }
    
    static var className: String {
        return String(describing: Self.self)
    }
}
