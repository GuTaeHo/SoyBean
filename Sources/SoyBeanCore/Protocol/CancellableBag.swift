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
