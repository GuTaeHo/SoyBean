import Foundation
import XCTest
@testable import SoyBeanUI

final class ToastOptionsTests: XCTestCase {
    func testToastDurationResolvesSeconds() {
        XCTAssertEqual(ToastDuration.short.seconds, 3)
        XCTAssertEqual(ToastDuration.long.seconds, 6)
        XCTAssertEqual(ToastDuration.custom(4.5).seconds, 4.5)
        XCTAssertEqual(ToastDuration.custom(0).seconds, 0)
        XCTAssertNil(ToastDuration.infinity.seconds)
    }

    func testInvalidCustomDurationUsesShortDuration() {
        for seconds in [-1, .infinity, -.infinity, .nan] as [TimeInterval] {
            XCTAssertEqual(ToastDuration.custom(seconds).seconds, ToastDuration.short.seconds)
        }
    }

    func testSystemThemeInvertsAppearanceAndExplicitThemesRemainFixed() {
        XCTAssertTrue(ToastTheme.system.usesLightAppearance(systemIsDark: true))
        XCTAssertFalse(ToastTheme.system.usesLightAppearance(systemIsDark: false))
        for systemIsDark in [false, true] {
            XCTAssertTrue(ToastTheme.light.usesLightAppearance(systemIsDark: systemIsDark))
            XCTAssertFalse(ToastTheme.dark.usesLightAppearance(systemIsDark: systemIsDark))
        }
    }
}
