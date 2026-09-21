import Foundation

public extension UserDefaults {
    /// Codable 값을 JSON 데이터로 저장합니다. `nil`이면 해당 키를 삭제합니다.
    func save<T: Encodable>(
        _ value: T?,
        forKey key: String,
        encoder: JSONEncoder = JSONEncoder()
    ) throws {
        guard let value else {
            removeObject(forKey: key)
            return
        }
        set(try encoder.encode(value), forKey: key)
    }

    /// JSON 데이터로 저장된 Codable 값을 불러옵니다.
    func load<T: Decodable>(
        _ type: T.Type,
        forKey key: String,
        decoder: JSONDecoder = JSONDecoder()
    ) throws -> T? {
        guard let data = data(forKey: key) else { return nil }
        return try decoder.decode(type, from: data)
    }

    /// Codable 값을 Property List 데이터로 저장합니다. `nil`이면 해당 키를 삭제합니다.
    func save<T: Encodable>(
        _ value: T?,
        forKey key: String,
        encoder: PropertyListEncoder
    ) throws {
        guard let value else {
            removeObject(forKey: key)
            return
        }
        set(try encoder.encode(value), forKey: key)
    }

    /// Property List 데이터로 저장된 Codable 값을 불러옵니다.
    func load<T: Decodable>(
        _ type: T.Type,
        forKey key: String,
        decoder: PropertyListDecoder
    ) throws -> T? {
        guard let data = data(forKey: key) else { return nil }
        return try decoder.decode(type, from: data)
    }
}
