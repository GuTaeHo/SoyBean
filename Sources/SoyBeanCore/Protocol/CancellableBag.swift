//
//  CancellableBag.swift
//  SoyBean
//
//  Created by 구태호 on 2/23/26.
//

import Combine

public protocol CancellableBag: AnyObject {
    var cancellables: Set<AnyCancellable> { get set }
}

public extension CancellableBag {
    /// 연산자처럼 사용 가능하도록하는 편의 메서드
    /// 기존 `.store(in: &cancellables)` 대신 간결하게 사용 가능
    ///
    /// # 사용 예시
    /// ```swift
    /// .sink { // TODO: }
    /// .store(cancellables)
    /// ```
    public func store(_ cancellable: AnyCancellable) {
        cancellable.store(in: &cancellables)
    }
}
