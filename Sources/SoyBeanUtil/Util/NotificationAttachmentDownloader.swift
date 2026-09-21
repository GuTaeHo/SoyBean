#if os(iOS)
import Foundation
import UniformTypeIdentifiers
import UserNotifications

/// 원격 파일을 내려받아 알림 이미지 첨부로 변환합니다.
public final class NotificationAttachmentDownloader {
    private let maximumByteCount: Int
    private let timeout: TimeInterval
    private let session: URLSession
    private let lock = NSLock()
    private var task: URLSessionDownloadTask?

    public init(
        maximumByteCount: Int = 10 * 1024 * 1024,
        timeout: TimeInterval = 15,
        session: URLSession = .shared
    ) {
        self.maximumByteCount = maximumByteCount
        self.timeout = timeout
        self.session = session
    }

    /// 이미지를 내려받아 알림 첨부로 반환합니다. 실패하면 `nil`을 반환합니다.
    public func attachment(
        for url: URL,
        completion: @escaping (UNNotificationAttachment?) -> Void
    ) {
        var request = URLRequest(url: url)
        request.timeoutInterval = timeout

        let downloadTask = session.downloadTask(with: request) { [maximumByteCount] location, response, _ in
            completion(
                Self.makeAttachment(
                    downloadedAt: location,
                    response: response,
                    sourceURL: url,
                    maximumByteCount: maximumByteCount
                )
            )
        }

        lock.lock()
        task?.cancel()
        task = downloadTask
        lock.unlock()
        downloadTask.resume()
    }

    /// 진행 중인 다운로드를 취소합니다.
    public func cancel() {
        lock.lock()
        task?.cancel()
        task = nil
        lock.unlock()
    }

    private static func makeAttachment(
        downloadedAt location: URL?,
        response: URLResponse?,
        sourceURL: URL,
        maximumByteCount: Int
    ) -> UNNotificationAttachment? {
        guard let location,
              let response = response as? HTTPURLResponse,
              200..<300 ~= response.statusCode,
              let fileExtension = imageFileExtension(for: response, sourceURL: sourceURL),
              let byteCount = byteCount(of: location),
              byteCount > 0,
              byteCount <= maximumByteCount else {
            return nil
        }

        return moveToAttachment(location, fileExtension: fileExtension)
    }

    private static func moveToAttachment(
        _ location: URL,
        fileExtension: String
    ) -> UNNotificationAttachment? {
        let fileManager = FileManager.default
        let directory = fileManager.temporaryDirectory.appendingPathComponent(
            UUID().uuidString,
            isDirectory: true
        )
        let destination = directory
            .appendingPathComponent("attachment")
            .appendingPathExtension(fileExtension)

        do {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
            try fileManager.moveItem(at: location, to: destination)
            return try UNNotificationAttachment(identifier: "", url: destination)
        } catch {
            try? fileManager.removeItem(at: directory)
            return nil
        }
    }

    private static func byteCount(of url: URL) -> Int? {
        let attributes = try? FileManager.default.attributesOfItem(atPath: url.path)
        return (attributes?[.size] as? NSNumber)?.intValue
    }

    private static func imageFileExtension(
        for response: HTTPURLResponse,
        sourceURL: URL
    ) -> String? {
        if let mimeType = response.mimeType,
           let type = UTType(mimeType: mimeType),
           type.conforms(to: .image),
           let fileExtension = type.preferredFilenameExtension {
            return fileExtension
        }

        let pathExtension = sourceURL.pathExtension.lowercased()
        guard !pathExtension.isEmpty,
              let type = UTType(filenameExtension: pathExtension),
              type.conforms(to: .image) else {
            return nil
        }
        return pathExtension
    }
}
#endif
