import Foundation

public extension Array {
    /**
     인덱스를 안전하게 참조합니다.
     
     ```swift
     let array = ["딸기", "우유", "바나나"]
     
     array[safe: 1] // "우유"
     array[safe: 3] // nil
     ```
     */
    subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
    
    /// 맨 앞에 요소를 추가합니다.
    mutating func prepend(_ newElement: Element) {
        insert(newElement, at: 0)
    }
}

extension Array where Element: Hashable {
    /// 중복값을 제거한 뒤 배열을 반환합니다.
    func distinct() -> [Element] {
        let set = Set(self)
        return Array(set)
    }
}
