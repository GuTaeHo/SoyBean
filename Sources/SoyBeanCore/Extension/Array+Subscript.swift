import Foundation

public extension Array {
    /**
     인덱스를 안전하게 참조
     
     - Returns: 범위가 배열을 벗어난 경우 `nil` 반환
     
     ```swift
     let array = ["딸기", "우유", "바나나"]
     
     array[safe: 1] // "우유"
     array[safe: 3] // nil
     ```
     */
    subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
    
    /// 맨 앞에 요소 추가
    mutating func prepend(_ newElement: Element) {
        insert(newElement, at: 0)
    }
}

public extension Array where Element: Hashable {
    /// 중복값을 제거한 뒤 배열 반환
    func removeDuplicates() -> [Element] {
        let set = Set(self)
        return Array(set)
    }
}
