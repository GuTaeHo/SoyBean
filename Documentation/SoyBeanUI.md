# SoyBeanUI

`SoyBeanUI`는 SwiftUI 공통 기능, 패키지 폰트, Toast 및 UIKit·AppKit 확장을 제공합니다. 플랫폼 전용 API는 표에 별도로 표시합니다.

정확한 매개변수, 반환값 및 실패 조건은 각 공개 선언의 `///` 문서 주석을 기준으로 합니다.

## SwiftUI 컴포넌트와 modifier

| API | 설명 | 플랫폼 |
| --- | --- | --- |
| `NumberAnimationTextView` | 숫자 변경 애니메이션을 제공하며 구버전 OS에서는 일반 텍스트로 표시합니다. | 전체 |
| `View.shake(amount:)` | 값이 애니메이션되는 동안 뷰를 좌우로 흔듭니다. | 전체 |
| `View.textStyle(...)` | 패키지 폰트, 크기, 색상 및 정렬을 한 번에 적용합니다. | 전체 |
| `View.indicator(isLoading:...)` | 로딩 중 내용을 흐리게 하고 입력을 막으며 선택적으로 원형 진행 상태를 표시합니다. | 전체 |
| `ValidationFeedback` | 검증 실패 입력 항목의 흔들림 횟수와 스크롤 대상을 관리합니다. | 전체 |
| `View.validationFieldID(_:)` | 입력 항목에 검증용 스크롤 식별자를 지정합니다. | 전체 |
| `View.scrollsToValidationField(_:proxy:)` | 실패한 입력 항목으로 스크롤하고 대상을 초기화합니다. | 전체 |
| `Animation.validationShake` | 입력 검증 실패에 사용하는 흔들림 애니메이션입니다. | 전체 |
| `View.contentMaxWidth(_:)` | iOS regular 너비 또는 macOS에서 콘텐츠 최대 너비를 제한합니다. | iOS, macOS |
| `View.keyboardAdaptive(_:isIgnoreSafeArea:)` | 키보드와 겹치는 만큼 하단 여백을 변경합니다. | iOS |
| `View.alertPresentationHaptics(isPresented:)` | 얼럿이 나타날 때 경고 햅틱을 실행합니다. | iOS |
| `View.controlValueHaptics(value:)` | 전달한 값이 바뀔 때 선택 햅틱을 실행합니다. | iOS |
| `View.loadCustomFontsForXcodePreviews()` | Xcode Preview에서 패키지 폰트를 등록합니다. | 전체 |

```swift
@State private var shakeAmount = 0.0

Text("입력값을 확인하세요")
    .shake(amount: shakeAmount)

Button("검증") {
    withAnimation(.linear(duration: 0.45)) {
        shakeAmount = shakeAmount == 0 ? 6 : 0
    }
}
```

로딩 화면은 앱 전용 이미지나 색상을 요구하지 않습니다.

```swift
Form {
    // 입력 화면
}
.indicator(isLoading: viewModel.isLoading)
.keyboardAdaptive()
.contentMaxWidth()
```

## 폰트

포함된 폰트는 앱 진입 시 `Font.registerFonts()`로 등록합니다.

| 글꼴 | `FontType` |
| --- | --- |
| Pretendard | `pretendardRegular`, `pretendardMedium`, `pretendardSemiBold`, `pretendardBold` |
| IBM Plex Sans KR | `IBMPlexThin`, `IBMPlexLight`, `IBMPlexRegular`, `IBMPlexMedium`, `IBMPlexSemiBold`, `IBMPlexBold` |
| NanumSquareRound | `nanumSquareRoundLight`, `nanumSquareRoundRegular`, `nanumSquareRoundBold`, `nanumSquareRoundExtraBold` |

| API | 설명 | 플랫폼 |
| --- | --- | --- |
| `Font.custom(_:size:)` | `FontType`으로 SwiftUI 폰트를 생성합니다. | 전체 |
| `Font.registerFonts()` | 번들 OTF 파일을 프로세스에 등록하고 성공한 이름을 반환합니다. | 전체 |
| `UIFont.custom(type:size:)` | 패키지 폰트 또는 대체 시스템 폰트를 반환합니다. | iOS |
| `UIFont.fontNames()` | 등록된 UIKit 폰트 이름을 반환합니다. | iOS |
| `NSFont.custom(type:size:)` | 패키지 폰트 또는 대체 시스템 폰트를 반환합니다. | macOS |
| `NSFont.fontNames()` | 등록된 AppKit 폰트 이름을 반환합니다. | macOS |

## 색상, 문자열 및 여백

| API | 설명 | 플랫폼 |
| --- | --- | --- |
| `Color.init(red:green:blue:alpha:)` | 0...1 RGB 값으로 색상을 생성하고 범위를 제한합니다. | 전체 |
| `Color.init(hex:alpha:)` | 3자리 또는 6자리 HEX 문자열로 색상을 생성합니다. | 전체 |
| `ColorConvertible` | SwiftUI `Color` 변환 속성을 요구합니다. | 전체 |
| `Color.toSwiftUIColor` | 현재 SwiftUI 색상을 반환합니다. | 전체 |
| `Color.toUIColor` | SwiftUI 색상을 UIKit 색상으로 변환합니다. | iOS |
| `Comparable.clamped(to:)` | 값을 닫힌 범위 안으로 제한합니다. | 전체 |
| `AttributedString.styledText(...)` | 패키지 폰트, 색상 및 정렬을 적용합니다. | iOS, macOS |
| `AttributedString.toMutable` | `NSMutableAttributedString`으로 변환합니다. | 전체 |
| `EdgeInsets` 편의 생성자 | 전체·가로·세로 여백을 간단히 생성합니다. | 전체 |
| `NSDirectionalEdgeInsets` 편의 생성자 | 전체·가로·세로 여백을 간단히 생성합니다. | 전체 |

## Toast

| API | 설명 | 플랫폼 |
| --- | --- | --- |
| `ToastDuration.short` | 3초 동안 표시합니다. | iOS, macOS |
| `ToastDuration.long` | 6초 동안 표시합니다. | iOS, macOS |
| `ToastType.positive` | 긍정 피드백을 표현합니다. iOS에서는 성공 햅틱이 발생합니다. | iOS, macOS |
| `ToastType.negative` | 흔들림 오류 피드백을 표현합니다. iOS에서는 오류 햅틱도 발생합니다. | iOS, macOS |
| `ToastView.init(message:)` | 플랫폼 네이티브 Toast 뷰를 직접 생성합니다. | iOS, macOS |
| `sbShowToast(...)` | 중앙 또는 상단 Toast를 표시하고 자동 제거합니다. | iOS, macOS |

`sbShowToast`는 다음 타입에서 제공됩니다.

- iOS: `UIView`, `UIViewController`, SwiftUI `View`
- macOS: `NSView`, `NSViewController`, SwiftUI `View`

SwiftUI API는 새 View를 반환하는 modifier가 아니라 표시 동작을 실행하는 메서드이므로 버튼 액션 등의 실행 시점에 호출합니다.

## UIKit 확장

다음 API는 iOS에서만 사용할 수 있습니다.

| 대상 | API | 설명 |
| --- | --- | --- |
| `HapticManager` | `shared` | 공용 햅틱 관리자입니다. |
| `HapticManager` | `notificationGenerator`·`selectionGenerator` | 재사용되는 UIKit feedback generator입니다. |
| `HapticManager` | `HapticType`·`start(_:)` | impact, notification 및 selection 햅틱을 표현하고 실행합니다. |
| `UIBarButtonItem` | `UIBarButtonItemTargetClosure` | 버튼과 함께 호출되는 closure 타입입니다. |
| `UIBarButtonItem` | closure 생성자 | title 또는 image 버튼 액션을 closure로 받습니다. |
| `UIColor` | RGB·HEX 생성자 | 정수 RGB 또는 HEX 문자열로 색상을 생성합니다. |
| `UIColor` | `toHexString()` | 색상을 6자리 HEX 문자열로 변환합니다. |
| `UIColor` | `toSwiftUIColor` | SwiftUI 색상으로 변환합니다. |
| `UIStackView` | 편의 생성자 | 축, 간격, 정렬, 배치, 여백 및 하위 뷰를 설정합니다. |
| `UIStackView` | `addArrangedSubviews` | 여러 arranged subview를 추가합니다. |
| `UIStackView` | `removeSubview` | arranged subview와 실제 뷰를 함께 제거합니다. |
| `UIStackView` | `removeAllSubviews` | 모든 arranged subview를 제거합니다. |
| `UITextField` | `addDoneButtonOnKeyboard` | 키보드 위에 닫기 버튼을 추가합니다. |
| `UITextField` | `addPreviousNextDoneOnKeyboard` | 이전·다음·완료 툴바를 추가합니다. |
| `UITextField` | `doneButtonAction` | 현재 텍스트필드의 입력을 종료합니다. |
| `UIView` | `convert(to:)` | 뷰 원점을 대상 좌표계로 변환합니다. |
| `UIView` | `hidden`·`display` | 선택적으로 애니메이션하며 표시 상태를 바꿉니다. |
| `UIView` | `shake` | 좌우 흔들림과 오류 햅틱을 실행합니다. |
| `UIView` | `addSubviews` | 여러 하위 뷰를 추가합니다. |
| `UIView` | `borderWidth`·`borderColor`·`cornerRadius` | Interface Builder에서 사용할 수 있는 레이어 속성입니다. |

### UIKit Combine Publisher

| 대상 | API | 설명 |
| --- | --- | --- |
| `UIControl` | `controlEventPublisher(for:)` | 지정한 control event를 `Void` 값으로 전달합니다. |
| `UIControl.Event` | `defaultValueEvents` | editing event와 value changed를 묶은 기본 이벤트입니다. |
| `UIButton` | `touchUpInsidePublisher` | 버튼 탭을 전달합니다. |
| `UIRefreshControl` | `isRefreshingPublisher` | 현재 값부터 새로고침 상태를 전달합니다. |
| `UIView` | `tapPublisher` | 새 탭 제스처를 뷰에 연결하고 recognizer를 전달합니다. |

구독을 취소하면 패키지가 추가한 action 또는 gesture recognizer도 제거됩니다.

## 시스템 화면 연결

다음 API는 iOS에서만 사용할 수 있습니다.

| API | 설명 |
| --- | --- |
| `ShareSheet` | `UIActivityViewController`를 SwiftUI sheet로 감쌉니다. |
| `View.shareSheet(isPresented:items:activities:)` | 문자열, URL, 이미지 등을 시스템 공유 화면으로 전달합니다. |
| `CalendarExportEvent` | 캘린더 편집 화면에 전달할 제목, 메모, 위치와 기간을 표현합니다. |
| `CalendarExportManager.export(_:)` | OS 버전과 권한 상태를 확인하고 캘린더 편집 화면을 준비합니다. |
| `View.calendarExport(using:)` | 캘린더 편집 화면과 접근 실패 안내를 표시합니다. |

```swift
@StateObject private var calendarExport = CalendarExportManager()

var body: some View {
    Button("캘린더에 추가") {
        calendarExport.export(
            CalendarExportEvent(
                title: "일정",
                startDate: startDate,
                endDate: endDate
            )
        )
    }
    .calendarExport(using: calendarExport)
}
```

iOS 16 이하에서는 캘린더 권한을 요청하므로 앱의 `Info.plist`에 `NSCalendarsUsageDescription`을 추가해야 합니다. `CalendarExportManager`는 일정을 바로 저장하지 않고 사용자가 내용을 확인하거나 수정할 수 있는 시스템 편집 화면을 표시합니다.

## Core Animation

| API | 설명 | 플랫폼 |
| --- | --- | --- |
| `CALayer.isExistLayer(name:)` | 이름이 같은 하위 레이어가 있는지 확인합니다. | iOS, macOS |
| `CALayer.removeLayer(name:)` | 이름이 같은 하위 레이어와 애니메이션을 제거합니다. | iOS, macOS |

`CALayer`는 watchOS에서 제공되지 않으므로 이 확장은 iOS와 macOS에서만 컴파일됩니다.

## 관련 문서

- [SoyBeanCore](SoyBeanCore.md)
- [SoyBeanUtil](SoyBeanUtil.md)
- [플랫폼 지원](PlatformSupport.md)
