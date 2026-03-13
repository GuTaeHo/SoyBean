//
//  Character+.swift
//  SoyBean
//
//  Created by 구태호 on 3/13/26.
//

import Foundation

public extension Character {
    /// 이모지 여부를 확인합니다.
    var isEmoji: Bool { isSimpleEmoji || isCombinedIntoEmoji }
    
    /// 하나의 스칼라로 이루어진 이모지일 경우 true 를 반환합니다.
    var isSimpleEmoji: Bool {
        guard let firstScalar = unicodeScalars.first else { return false }
        return firstScalar.properties.isEmoji && firstScalar.value > 0x238C
    }

    /// 다수의 스칼라로 이루어진 이모지일 경우 true 를 반환합니다.
    var isCombinedIntoEmoji: Bool { unicodeScalars.count > 1 && unicodeScalars.first?.properties.isEmoji ?? false }
}
