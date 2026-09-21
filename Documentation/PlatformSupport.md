# 플랫폼 지원

SoyBean은 `Package.swift`에서 iOS 15+, macOS 12+, watchOS 8+를 선언합니다. 제품을 추가할 수 있다는 의미와 모든 API가 모든 플랫폼에 존재한다는 의미는 다릅니다.

## 제품 지원

| 제품 | iOS | macOS | watchOS |
| --- | --- | --- | --- |
| `SoyBean` | 지원 | 지원 | 지원 |
| `SoyBeanCore` | 지원 | 지원 | 지원 |
| `SoyBeanUI` | 지원 | 지원 | 제한적 지원 |
| `SoyBeanUtil` | 지원 | 지원 | 제한적 지원 |

`SoyBeanUI`와 `SoyBeanUtil`은 watchOS에서 컴파일되지만 UIKit, AppKit, Toast, 앱 열기 및 클립보드 API는 노출하지 않습니다.

## 기능별 지원

| 기능 | iOS | macOS | watchOS |
| --- | --- | --- | --- |
| Foundation·Swift 확장 | 지원 | 지원 | 지원 |
| 앱 버전 비교·Codable 변환 | 지원 | 지원 | 지원 |
| OSLog 로깅 | 지원 | 지원 | 지원 |
| Combine 공통 확장 | 지원 | 지원 | 지원 |
| 키보드 Publisher | 지원 | 미지원 | 미지원 |
| 공통 SwiftUI 컴포넌트 | 지원 | 지원 | 지원 |
| 콘텐츠 최대 너비 | 지원 | 지원 | 미지원 |
| 키보드 적응·SwiftUI 햅틱 | 지원 | 미지원 | 미지원 |
| 패키지 폰트 | 지원 | 지원 | 지원 |
| UIKit 확장과 햅틱 | 지원 | 미지원 | 미지원 |
| UIKit Combine Publisher | 지원 | 미지원 | 미지원 |
| 공유 화면·캘린더 내보내기 | 지원 | 미지원 | 미지원 |
| AppKit 폰트 확장 | 미지원 | 지원 | 미지원 |
| Core Animation 레이어 확장 | 지원 | 지원 | 미지원 |
| Toast | UIKit | AppKit | 미지원 |
| 날짜·정규식·JWT 유틸리티 | 지원 | 지원 | 지원 |
| Keychain | 지원 | 지원 | 지원 |
| UserDefaults 마이그레이션 | 지원 | 지원 | 지원 |
| Codable UserDefaults·Multipart | 지원 | 지원 | 지원 |
| 알림 첨부 다운로드 | 지원 | 미지원 | 미지원 |
| 앱 열기 유틸리티 | 지원, App Extension 제외 | 미지원 | 미지원 |
| 클립보드 | `UIPasteboard` | `NSPasteboard` | 미지원 |

## 조건부 컴파일 원칙

- UIKit에 의존하는 import와 선언은 `#if os(iOS)` 안에 둡니다.
- AppKit에 의존하는 import와 선언은 `#if os(macOS)` 안에 둡니다.
- `CALayer`처럼 watchOS에서 사용할 수 없는 API는 iOS와 macOS로 제한합니다.
- 공통 SwiftUI API가 더 높은 OS 버전을 요구하면 런타임 availability 검사를 제공합니다.
- `SoyBeanCore`에는 `SoyBeanUI` 또는 `SoyBeanUtil` 의존성을 추가하지 않습니다.

## 변경 전 검증

공통 검증:

```sh
swift build
swift test
git diff --check
cmp -s AGENTS.md CLAUDE.md
```

플랫폼 전용 코드를 변경한 경우 설치된 Apple SDK를 사용하여 iOS 및 watchOS 빌드도 확인합니다. 최소 검증 행렬은 다음과 같습니다.

| 변경 영역 | macOS | iOS | watchOS |
| --- | --- | --- | --- |
| `SoyBeanCore` 공통 코드 | 필수 | 필수 | 필수 |
| `SoyBeanUI` 공통 SwiftUI 코드 | 필수 | 필수 | 필수 |
| UIKit·키보드·햅틱 | 해당 없음 | 필수 | 해당 없음 |
| AppKit·macOS Toast | 필수 | 해당 없음 | 해당 없음 |
| `SoyBeanUtil` 공통 코드 | 필수 | 필수 | 필수 |

## 모듈별 기능

- [SoyBeanCore](SoyBeanCore.md)
- [SoyBeanUI](SoyBeanUI.md)
- [SoyBeanUtil](SoyBeanUtil.md)
