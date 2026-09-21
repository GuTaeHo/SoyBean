import Foundation

/// 앱 버전 문자열을 숫자 단위로 비교할 수 있게 표현합니다.
///
/// `1.2`와 `1.2.0`은 같은 버전으로 판단하며, 각 단위에는 숫자만 허용합니다.
public struct AppVersion: Comparable, Hashable, Sendable, CustomStringConvertible {
    /// 전달받은 원본 버전 문자열입니다.
    public let value: String

    /// 비교에 사용하는 숫자 단위입니다.
    public let numbers: [Int]

    public var description: String { value }

    /// 점으로 구분된 앱 버전 문자열을 변환합니다.
    ///
    /// - Throws: 빈 값, 빈 단위 또는 숫자가 아닌 단위가 있으면 `AppVersionError.invalidFormat`을 던집니다.
    public init(_ value: String) throws {
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        let values = trimmedValue.split(separator: ".", omittingEmptySubsequences: false)

        guard !trimmedValue.isEmpty, !values.isEmpty else {
            throw AppVersionError.invalidFormat(value)
        }

        var numbers: [Int] = []
        numbers.reserveCapacity(values.count)

        for value in values {
            guard !value.isEmpty,
                  value.allSatisfy(\.isNumber),
                  let number = Int(value) else {
                throw AppVersionError.invalidFormat(trimmedValue)
            }
            numbers.append(number)
        }

        while numbers.count > 1, numbers.last == 0 {
            numbers.removeLast()
        }

        self.value = trimmedValue
        self.numbers = numbers
    }

    public static func == (lhs: AppVersion, rhs: AppVersion) -> Bool {
        lhs.numbers == rhs.numbers
    }

    public static func < (lhs: AppVersion, rhs: AppVersion) -> Bool {
        let count = max(lhs.numbers.count, rhs.numbers.count)

        for index in 0..<count {
            let lhsNumber = lhs.numbers[safe: index] ?? 0
            let rhsNumber = rhs.numbers[safe: index] ?? 0

            if lhsNumber != rhsNumber {
                return lhsNumber < rhsNumber
            }
        }

        return false
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(numbers)
    }
}

/// 앱 버전 문자열 변환 오류입니다.
public enum AppVersionError: LocalizedError, Equatable {
    case invalidFormat(String)

    public var errorDescription: String? {
        switch self {
        case .invalidFormat(let value):
            return "잘못된 앱 버전 형식입니다: \(value)"
        }
    }
}
