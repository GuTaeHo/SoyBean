import Foundation

/// Codable 값 변환 중 발생하는 오류입니다.
public enum CodableConvertError: LocalizedError {
    case stringConvertFailed
    case dictionaryConvertFailed

    public var errorDescription: String? {
        switch self {
        case .stringConvertFailed:
            return "JSON 문자열로 변환할 수 없습니다"
        case .dictionaryConvertFailed:
            return "JSON 딕셔너리로 변환할 수 없습니다"
        }
    }
}

public extension Encodable {
    /// 값을 JSON 데이터로 변환합니다.
    func toJSONData(encoder: JSONEncoder = JSONEncoder()) throws -> Data {
        try encoder.encode(self)
    }

    /// 값을 JSON 문자열로 변환합니다.
    ///
    /// - Parameter isPretty: `true`이면 들여쓰기를 적용합니다.
    func toJSONString(
        isPretty: Bool = false,
        encoder: JSONEncoder = JSONEncoder()
    ) throws -> String {
        let encodedData = try encoder.encode(self)
        let data: Data

        if isPretty {
            let object = try JSONSerialization.jsonObject(with: encodedData)
            data = try JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .sortedKeys])
        } else {
            data = encodedData
        }

        guard let string = String(data: data, encoding: .utf8) else {
            throw CodableConvertError.stringConvertFailed
        }
        return string
    }

    /// 값을 JSON 딕셔너리로 변환합니다.
    func toJSONDictionary(encoder: JSONEncoder = JSONEncoder()) throws -> [String: Any] {
        let data = try encoder.encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw CodableConvertError.dictionaryConvertFailed
        }
        return dictionary
    }
}

public extension Data {
    /// JSON 데이터를 지정한 객체로 변환합니다.
    func toObject<T: Decodable>(
        _ type: T.Type,
        decoder: JSONDecoder = JSONDecoder()
    ) throws -> T {
        try decoder.decode(type, from: self)
    }
}

public extension String {
    /// JSON 문자열을 지정한 객체로 변환합니다.
    func toObject<T: Decodable>(
        _ type: T.Type,
        decoder: JSONDecoder = JSONDecoder()
    ) throws -> T {
        guard let data = data(using: .utf8) else {
            throw CodableConvertError.stringConvertFailed
        }
        return try decoder.decode(type, from: data)
    }
}

public extension Dictionary where Key == String, Value == Any {
    /// JSON 딕셔너리를 지정한 객체로 변환합니다.
    func toObject<T: Decodable>(
        _ type: T.Type,
        decoder: JSONDecoder = JSONDecoder()
    ) throws -> T {
        let data = try JSONSerialization.data(withJSONObject: self)
        return try decoder.decode(type, from: data)
    }
}
