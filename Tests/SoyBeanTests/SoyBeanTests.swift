import XCTest
import Combine
import Foundation
import SwiftUI
@testable import SoyBeanCore
@testable import SoyBeanUI
@testable import SoyBeanUtil

private struct TestProfile: Codable, Equatable {
    let name: String
    let age: Int
}

private final class TestSubscriberOwner {
    var values: [Int] = []
    var isFinished = false
}

final class SoybeanTests: XCTestCase {
    func testSafeArraySubscript() {
        let values = ["first", "second"]

        XCTAssertEqual(values[safe: 1], "second")
        XCTAssertNil(values[safe: 2])
    }

    func testStringToDateUsesRequestedGMTOffset() throws {
        let utcDate = try XCTUnwrap(
            "1970-01-01 00:00:00".toDate(secondsFromGMT: 0)
        )
        let koreaDate = try XCTUnwrap(
            "1970-01-01 00:00:00".toDate(secondsFromGMT: 9)
        )

        XCTAssertEqual(utcDate.timeIntervalSince(koreaDate), 9 * 60 * 60)
    }

    func testMalformedJWTDoesNotCrash() {
        XCTAssertTrue(DecodeUtil.jwtDecode(jwtToken: "invalid-token").isEmpty)
    }

    func testEdgeInsetsConvenienceInitializer() {
        let insets = EdgeInsets(horizontal: 12, vertical: 8)

        XCTAssertEqual(insets.top, 8)
        XCTAssertEqual(insets.leading, 12)
        XCTAssertEqual(insets.bottom, 8)
        XCTAssertEqual(insets.trailing, 12)
    }

    func testAppVersionComparesEachNumber() throws {
        XCTAssertEqual(try AppVersion("1.2"), try AppVersion("1.2.0"))
        XCTAssertGreaterThan(try AppVersion("1.10.0"), try AppVersion("1.9.9"))
        XCTAssertLessThan(try AppVersion("2.0"), try AppVersion("10.0"))
        XCTAssertThrowsError(try AppVersion("1.beta.0"))
    }

    func testCodableJSONConversion() throws {
        let profile = TestProfile(name: "태호", age: 30)

        let data = try profile.toJSONData()
        let string = try profile.toJSONString()
        let dictionary = try profile.toJSONDictionary()

        XCTAssertEqual(try data.toObject(TestProfile.self), profile)
        XCTAssertEqual(try string.toObject(TestProfile.self), profile)
        XCTAssertEqual(try dictionary.toObject(TestProfile.self), profile)
        XCTAssertEqual(dictionary["name"] as? String, "태호")
    }

    func testUserDefaultsCodableStorage() throws {
        let suiteName = "SoyBeanTests.UserDefaults.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let profile = TestProfile(name: "콩", age: 1)
        try defaults.save(profile, forKey: "profile")

        let savedProfile = try defaults.load(TestProfile.self, forKey: "profile")
        XCTAssertEqual(savedProfile, profile)

        try defaults.save(nil as TestProfile?, forKey: "profile")
        XCTAssertNil(try defaults.load(TestProfile.self, forKey: "profile"))

        try defaults.save(
            profile,
            forKey: "propertyListProfile",
            encoder: PropertyListEncoder()
        )
        let propertyListProfile = try defaults.load(
            TestProfile.self,
            forKey: "propertyListProfile",
            decoder: PropertyListDecoder()
        )
        XCTAssertEqual(propertyListProfile, profile)
    }

    func testMultipartFormDataEncoding() throws {
        var formData = MultipartFormData(boundary: "test-boundary")
        formData.append(name: "title", value: "안녕하세요")
        formData.append(
            name: "image",
            fileName: "photo.jpg",
            mimeType: "image/jpeg",
            data: Data([0x01, 0x02])
        )

        var request = URLRequest(url: try XCTUnwrap(URL(string: "https://example.com")))
        formData.apply(to: &request)

        XCTAssertEqual(
            request.value(forHTTPHeaderField: "Content-Type"),
            "multipart/form-data; boundary=test-boundary"
        )
        let body = try XCTUnwrap(request.httpBody)
        XCTAssertTrue(body.starts(with: Data("--test-boundary\r\n".utf8)))
        XCTAssertTrue(body.contains(Data("name=\"title\"".utf8)))
        XCTAssertTrue(body.contains(Data([0x01, 0x02])))
        let endBoundary = Data("--test-boundary--\r\n".utf8)
        XCTAssertEqual(body.suffix(endBoundary.count), endBoundary)
    }

    func testWeakSinkReceivesValueAndCompletion() {
        let subject = PassthroughSubject<Int, Never>()
        let owner = TestSubscriberOwner()
        let cancellable = subject.sink(
            with: owner,
            receiveCompletion: { owner, completion in
                if case .finished = completion {
                    owner.isFinished = true
                }
            },
            receiveValue: { owner, value in
                owner.values.append(value)
            }
        )

        subject.send(7)
        subject.send(completion: .finished)

        XCTAssertEqual(owner.values, [7])
        XCTAssertTrue(owner.isFinished)
        withExtendedLifetime(cancellable) { }
    }

    func testWeakSinkDoesNotRetainOwner() {
        let subject = PassthroughSubject<Int, Never>()
        var owner: TestSubscriberOwner? = TestSubscriberOwner()
        weak let weakOwner = owner
        let cancellable = subject.sink(
            with: owner!,
            receiveCompletion: { _, _ in },
            receiveValue: { _, _ in }
        )

        owner = nil

        XCTAssertNil(weakOwner)
        withExtendedLifetime(cancellable) { }
    }

    func testSharedDateFormatterIgnoresDeviceLocaleAndCalendar() throws {
        let formatter = DateFormatter.shared

        XCTAssertEqual(formatter.locale.identifier, "en_US_POSIX")
        XCTAssertEqual(formatter.calendar.identifier, .gregorian)
        let date = try XCTUnwrap(formatter.date(from: "2026-09-21 15:30:05"))
        XCTAssertEqual(formatter.string(from: date), "2026-09-21 15:30:05")
    }

    func testFormatDateKeepsGregorianYear() throws {
        XCTAssertEqual(try FormatUtil.formatDate("2026-09-21 15:30:05", to: .yy_Dot_MM_Dot_dd), "26.09.21")
    }

    func testEventLimiterDebounceRunsOnlyLastEvent() async throws {
        let limiter = EventLimiter()
        let recorder = TestEventRecorder()

        for value in 1...3 {
            limiter.execute(type: .debounce, duration: 0.1) { await recorder.append(value) }
            try await Task.sleep(nanoseconds: 20_000_000)
        }
        try await Task.sleep(nanoseconds: 300_000_000)

        let values = await recorder.values
        XCTAssertEqual(values, [3])
    }

    func testEventLimiterThrottleRunsFirstEventOnly() async throws {
        let limiter = EventLimiter()
        let recorder = TestEventRecorder()

        for value in 1...3 {
            limiter.execute(type: .throttle, duration: 0.3) { await recorder.append(value) }
            try await Task.sleep(nanoseconds: 20_000_000)
        }
        try await Task.sleep(nanoseconds: 100_000_000)

        let values = await recorder.values
        XCTAssertEqual(values, [1])
    }

    func testAttributedStringBuilderCombinesDefaultAndPieceAttributes() throws {
        let attributed: NSAttributedString = try XCTUnwrap(
            AttributedStringBuilder
                .factory(default: [.kerning(1), .lineSpacing(4)])
                .text("가")
                .space()
                .text("나", attributes: [.kerning(2)])
                .build()
        )

        XCTAssertEqual(attributed.string, "가 나")
        XCTAssertEqual(attributed.attribute(.kern, at: 0, effectiveRange: nil) as? CGFloat, 1)
        XCTAssertEqual(attributed.attribute(.kern, at: 2, effectiveRange: nil) as? CGFloat, 2)
        let paragraphStyle = attributed.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle
        XCTAssertEqual(paragraphStyle?.lineSpacing, 4)
    }

    func testAttributedStringBuilderReturnsIndependentCopy() throws {
        let builder = AttributedStringBuilder.factory().text("가")
        let first: NSAttributedString = try XCTUnwrap(builder.build())
        builder.text("나")

        XCTAssertEqual(first.string, "가")
    }
}

private actor TestEventRecorder {
    private(set) var values: [Int] = []

    func append(_ value: Int) {
        values.append(value)
    }
}
