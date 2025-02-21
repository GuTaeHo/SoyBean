//
//  Combine+Publisher.swift
//  SoyBean
//
//  Created by 구태호 on 2/21/25.
//

import Combine
import SwiftUI


public extension Publisher {
    var main: AnyPublisher<Output, Failure> {
        return receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }
}
