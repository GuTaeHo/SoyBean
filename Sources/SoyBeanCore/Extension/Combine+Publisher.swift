//
//  Combine+Publisher.swift
//  SoyBean
//
//  Created by 구태호 on 2/21/25.
//

import Combine
import SwiftUI


public extension Publisher {
    /// 다운스트림 퍼블리셔를 메인 스레드가 처리하도록 변경
    var main: AnyPublisher<Output, Failure> {
        return receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }
    
    /// Publisher 를 약한 참조로 구독
    /// - Parameters:
    ///     - object: 약한 참조로 캡쳐될 Reference Type 객체
    ///     - receiveValue: Publisher 로 전달된 값이 포함된 클로저
    /// - Note: object 가 더 이상 참조될 수 없다면 **receiveValue** 콜백이 호출되지 않음.
    func sink<Object: AnyObject>(
        with object: Object,
        receiveValue: @escaping (Object, Output) -> Void
    ) -> AnyCancellable where Failure == Never {
        return sink(receiveValue: { [weak object] value in
            guard let object else { return }
            receiveValue(object, value)
        })
    }
}

