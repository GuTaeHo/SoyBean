# SoyBean

SoyBean은 Apple 플랫폼 앱에서 반복적으로 사용하는 확장, 로깅, 포맷 변환, 유효성 검사, 보안 저장소 및 UI 컴포넌트를 모아 둔 Swift Package입니다. 외부 패키지 의존성 없이 필요한 모듈만 선택해서 사용할 수 있습니다.

## 요구 사항

| 항목 | 최소 사양 |
| --- | --- |
| Swift tools | 5.10 |
| iOS | 15 이상 |
| macOS | 12 이상 |
| watchOS | 8 이상 |

플랫폼은 위와 같이 선언되어 있지만 모든 API가 세 플랫폼에서 동일하게 제공되는 것은 아닙니다. UIKit API와 햅틱, 키보드 Publisher는 iOS 전용이며 AppKit API는 macOS 전용입니다. 자세한 내용은 [플랫폼 지원](Documentation/PlatformSupport.md)을 참고하세요.

## 설치

### Xcode에서 추가

1. `File > Add Package Dependencies`를 선택합니다.
2. 다음 저장소 주소를 입력합니다.

   ```text
   https://github.com/GuTaeHo/SoyBean.git
   ```

3. 사용할 제품과 적용할 타깃을 선택한 뒤 `Add Package`를 누릅니다.

![Xcode 패키지 추가 화면](./Images/img_demo_installation1.png)

### Package.swift에서 추가

```swift
dependencies: [
    .package(url: "https://github.com/GuTaeHo/SoyBean.git", from: "1.2.24")
],
targets: [
    .target(
        name: "MyApp",
        dependencies: [
            .product(name: "SoyBean", package: "SoyBean")
        ]
    )
]
```

예시는 현재 저장소의 최신 태그인 `1.2.24`를 기준으로 합니다.

## 제공 제품

| 제품 | 역할 | 상세 문서 |
| --- | --- | --- |
| `SoyBean` | 아래 세 모듈을 다시 내보내는 통합 모듈 | 이 README |
| `SoyBeanCore` | 오류, 로깅, Foundation·Swift·Combine 확장 | [SoyBeanCore](Documentation/SoyBeanCore.md) |
| `SoyBeanUI` | SwiftUI 컴포넌트, 폰트, UIKit·AppKit 보조 기능 | [SoyBeanUI](Documentation/SoyBeanUI.md) |
| `SoyBeanUtil` | 포맷, 검증, 디코딩, Keychain 및 앱 유틸리티 | [SoyBeanUtil](Documentation/SoyBeanUtil.md) |

전체 기능이 필요하면 통합 제품을 사용합니다.

```swift
import SoyBean
```

필요한 기능만 사용하려면 개별 제품을 의존성에 추가한 뒤 직접 import합니다.

```swift
import SoyBeanCore
import SoyBeanUI
import SoyBeanUtil
```

## 빠른 사용법

### 로깅과 기본 확장

```swift
import SoyBeanCore

Log.info("화면 진입")

let value = ["딸기", "우유"][safe: 1]
let digest = "SoyBean".toSHA256
```

로그는 `DEBUG` 빌드에서 OSLog로 출력됩니다.

### 버전 비교와 Codable 저장

```swift
import SoyBean

let needsUpdate = try AppVersion(Bundle.main.appVersion) < AppVersion("2.4.0")

try UserDefaults.standard.save(profile, forKey: "profile")
let savedProfile = try UserDefaults.standard.load(Profile.self, forKey: "profile")
```

`AppVersion`은 `1.10`과 `1.9`처럼 자리수가 다른 숫자 버전을 올바르게 비교합니다. Codable 값은 JSON 데이터로 저장되며 `nil`을 저장하면 해당 키가 삭제됩니다.

### 포맷과 유효성 검사

```swift
import SoyBeanUtil

let displayDate = try FormatUtil.formatDate(
    "2026-07-21 14:30:00",
    to: .yy_Dot_MM_Dot_dd
)

let isEmail = RegExpUtil.evaluate(
    type: .email,
    compareWith: "user@example.com"
)
```

### Keychain

```swift
import SoyBeanUtil

KeychainManager.shared.save("access-token", forKey: "token")
let token = KeychainManager.shared.load(String.self, forKey: "token")
```

저장할 값은 `Codable`을 준수해야 합니다. Keychain Sharing을 사용하는 경우 `groupAt`에 타깃에 등록된 Access Group을 전달합니다.

### 커스텀 폰트

```swift
import SwiftUI
import SoyBeanUI

@main
struct MyApp: App {
    init() {
        Font.registerFonts()
    }

    var body: some Scene {
        WindowGroup {
            Text("SoyBean")
                .textStyle(
                    fontType: .pretendardSemiBold,
                    fontSize: 18,
                    color: .primary
                )
        }
    }
}
```

### Toast

```swift
import SoyBeanUI

view.sbShowToast(
    message: "저장되었습니다.",
    duration: .short,
    isShowTop: true,
    type: .positive
)
```

Toast는 iOS의 `UIView`·`UIViewController`·SwiftUI `View`와 macOS의 `NSView`·`NSViewController`·SwiftUI `View`에서 사용할 수 있습니다. `.short`는 3초, `.long`은 6초이며 `.negative` 타입에는 흔들림 효과가 적용됩니다. 햅틱은 iOS에서만 발생합니다.

SwiftUI 로딩·키보드 대응·검증 피드백과 iOS 공유 화면·캘린더 내보내기는 [SoyBeanUI 전체 기능](Documentation/SoyBeanUI.md), multipart 본문과 알림 첨부 다운로드는 [SoyBeanUtil 전체 기능](Documentation/SoyBeanUtil.md)에서 예제를 확인할 수 있습니다.

## 문서 구성

README는 설치, 제품 선택 및 대표 사용법만 다룹니다. 전체 공개 기능 목록과 플랫폼 조건은 다음 문서에서 관리합니다.

- [SoyBeanCore 전체 기능](Documentation/SoyBeanCore.md)
- [SoyBeanUI 전체 기능](Documentation/SoyBeanUI.md)
- [SoyBeanUtil 전체 기능](Documentation/SoyBeanUtil.md)
- [플랫폼 지원](Documentation/PlatformSupport.md)

각 API의 정확한 매개변수, 반환값 및 실패 조건은 공개 선언의 `///` 문서 주석을 기준으로 합니다.

## 모듈 구조

```text
SoyBean
├── SoyBeanCore
├── SoyBeanUI ──> SoyBeanCore
└── SoyBeanUtil ─> SoyBeanCore
```

`SoyBeanCore`는 다른 하위 모듈에 의존하지 않습니다. UI와 유틸리티 모듈은 Core에만 의존합니다.

## 로컬 검증

```sh
swift build
swift test
```

플랫폼 전용 코드를 수정했다면 iOS 및 watchOS 타깃도 함께 컴파일해야 합니다. 검증 범위는 [플랫폼 지원 문서](Documentation/PlatformSupport.md)에 정리되어 있습니다.
