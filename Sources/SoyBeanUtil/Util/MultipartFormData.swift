import Foundation

/// 텍스트와 파일을 포함하는 `multipart/form-data` 요청 본문을 만듭니다.
public struct MultipartFormData {
    private let boundary: String
    private var body = Data()

    public init(boundary: String = "SoyBeanBoundary-\(UUID().uuidString)") {
        let safeBoundary = boundary
            .replacingOccurrences(of: "\r", with: "")
            .replacingOccurrences(of: "\n", with: "")
        self.boundary = safeBoundary.isEmpty ? "SoyBeanBoundary-\(UUID().uuidString)" : safeBoundary
    }

    /// 요청 헤더에 넣을 Content-Type 값입니다.
    public var contentType: String {
        "multipart/form-data; boundary=\(boundary)"
    }

    /// 문자열 파트를 추가합니다. 값이 `nil`이면 추가하지 않습니다.
    public mutating func append(name: String, value: String?) {
        guard let value else { return }
        appendHeader(
            disposition: "form-data; name=\"\(safeHeaderValue(name))\"",
            contentType: nil
        )
        append(value)
        append("\r\n")
    }

    /// 데이터 파트를 추가합니다.
    public mutating func append(
        name: String,
        fileName: String,
        mimeType: String,
        data: Data
    ) {
        appendHeader(
            disposition: "form-data; name=\"\(safeHeaderValue(name))\"; filename=\"\(safeHeaderValue(fileName))\"",
            contentType: safeHeaderValue(mimeType)
        )
        body.append(data)
        append("\r\n")
    }

    /// 종료 경계를 포함한 요청 본문을 반환합니다.
    public func encoded() -> Data {
        var encoded = body
        encoded.append(Data("--\(boundary)--\r\n".utf8))
        return encoded
    }

    /// 요청에 Content-Type과 본문을 적용합니다.
    public func apply(to request: inout URLRequest) {
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.httpBody = encoded()
    }

    private mutating func appendHeader(disposition: String, contentType: String?) {
        append("--\(boundary)\r\n")
        append("Content-Disposition: \(disposition)\r\n")
        if let contentType {
            append("Content-Type: \(contentType)\r\n")
        }
        append("\r\n")
    }

    private mutating func append(_ string: String) {
        body.append(Data(string.utf8))
    }

    private func safeHeaderValue(_ value: String) -> String {
        value
            .replacingOccurrences(of: "\r", with: "")
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\"", with: "%22")
    }
}
