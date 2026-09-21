# SoyBeanCore

`SoyBeanCore`는 다른 SoyBean 하위 모듈에 의존하지 않는 공통 기능을 제공합니다. 별도 표기가 없는 API는 iOS 15+, macOS 12+, watchOS 8+에서 사용할 수 있습니다.

정확한 매개변수, 반환값 및 실패 조건은 각 공개 선언의 `///` 문서 주석을 기준으로 합니다.

## 오류와 로깅

| API | 설명 |
| --- | --- |
| `SoyBeanError` | 메시지, 잘못된 URL, 외부 앱 열기 실패 및 날짜 포맷 오류를 표현합니다. |
| `Log.info` | `DEBUG` 빌드에서 정보 로그를 출력합니다. |
| `Log.debug` | `DEBUG` 빌드에서 디버그 로그를 출력합니다. |
| `Log.error` | `DEBUG` 빌드에서 오류 로그를 출력합니다. |
| `Log.custom` | OSLog 카테고리와 레벨을 직접 지정합니다. |

```swift
Log.custom(category: "Network", level: .error, "요청 실패")
```

## 컬렉션과 기본 타입

| 대상 | API | 설명 |
| --- | --- | --- |
| `Array` | `[safe:]` | 범위를 벗어나면 `nil`을 반환합니다. |
| `Array` | `prepend(_:)` | 배열 맨 앞에 요소를 삽입합니다. |
| `Array where Element: Hashable` | `removeDuplicates()` | 중복을 제거한 새 배열을 반환합니다. 반환 순서는 보장하지 않습니다. |
| `Character` | `isEmoji` | 단일 또는 조합 이모지인지 확인합니다. |
| `Character` | `isSimpleEmoji` | 단일 Unicode scalar 이모지인지 확인합니다. |
| `Character` | `isCombinedIntoEmoji` | 여러 scalar로 조합된 이모지인지 확인합니다. |
| `Int` | `toString` | 문자열로 변환합니다. |
| `Int` | `toCGFloat` | `CGFloat`로 변환합니다. |
| `Int` | `toDouble` | `Double`로 변환합니다. |
| `Int` | `toDecimalString` | 천 단위 구분자가 적용된 문자열을 반환합니다. |
| `Double` | `toInt` | 소수 부분을 버리고 `Int`로 변환합니다. |
| `CGSize` | `+` | 두 크기의 너비와 높이를 각각 더합니다. |

## 문자열과 데이터

| 대상 | API | 설명 |
| --- | --- | --- |
| `String` | `toOptionalIfEmpty` | 빈 문자열이면 `nil`을 반환합니다. |
| `String` | `isBlank` | 공백과 줄바꿈만 포함하는지 확인합니다. |
| `String` | `toPrettyJSON` | JSON 문자열을 들여쓰기된 형태로 변환합니다. |
| `String` | `toSHA256` | SHA-256 값을 16진수 문자열로 반환합니다. |
| `String` | `toDate(_:secondsFromGMT:)` | 지정한 포맷과 GMT 시간 오프셋으로 날짜를 해석합니다. |
| `Optional<String>` | `toEmptyIfOptional` | `nil`을 빈 문자열로 변환합니다. |
| `Data` | `toJSONDictionary` | JSON 데이터를 딕셔너리로 변환합니다. |
| `Encodable` | `toJSONData(encoder:)` | 값을 JSON 데이터로 변환합니다. |
| `Encodable` | `toJSONString(isPretty:encoder:)` | 값을 일반 또는 들여쓰기된 JSON 문자열로 변환합니다. |
| `Encodable` | `toJSONDictionary(encoder:)` | 객체 형태의 값을 JSON 딕셔너리로 변환합니다. |
| `Data`·`String`·`[String: Any]` | `toObject(_:decoder:)` | JSON 값을 지정한 `Decodable` 타입으로 변환합니다. |
| `NSObject` | `className` | 인스턴스 또는 타입의 클래스 이름을 반환합니다. |

`toDate`의 `secondsFromGMT`는 기존 API 이름을 유지하지만 값은 시간 단위입니다. 한국 표준시는 `9`, UTC는 `0`을 전달합니다.

## 날짜와 앱 정보

| 대상 | API | 설명 |
| --- | --- | --- |
| `Date` | `CompareType` | 날짜 비교 결과인 `.early`, `.same`, `.late`를 표현합니다. |
| `Date` | `timeDifferenceToSecond(_:)` | 수신 날짜와 비교 날짜의 차이를 초 단위로 반환합니다. |
| `Date` | `compareDates(_:targetDate:format:)` | 문자열 날짜 두 개를 변환하여 비교합니다. |
| `Date` | `remainingDays(_:format:)` | 현재부터 대상 날짜까지 남은 일수를 반환합니다. |
| `DateFormatter` | `shared` | `yyyy-MM-dd HH:mm:ss` 공통 포맷터입니다. 속성을 변경하면 안 됩니다. |
| `Bundle` | `AppInstallEnvironment` | 직접 설치, TestFlight 및 App Store 설치를 구분합니다. |
| `Bundle.AppInstallEnvironment` | `name` | 설치 환경을 표시용 한글 이름으로 반환합니다. |
| `Bundle` | `appInstallEnvironment` | 현재 앱의 설치 환경을 반환합니다. |
| `Bundle` | `appBundleID` | 메인 번들의 식별자를 반환합니다. |
| `Bundle` | `appName` | 메인 번들의 표시 이름을 반환합니다. |
| `Bundle` | `appVersion` | 앱 버전을 반환합니다. |
| `Bundle` | `appBuildNumber` | 빌드 번호를 반환합니다. |
| `AppVersion` | `init(_:)` | 점으로 구분된 숫자 버전을 비교 가능한 값으로 변환합니다. |

`AppVersion`은 문자열 비교와 달리 `1.10`을 `1.9`보다 높은 버전으로 판단하며, `1.2`와 `1.2.0`은 같은 버전으로 취급합니다.

```swift
let current = try AppVersion(Bundle.main.appVersion)
let minimum = try AppVersion("2.4.0")

if current < minimum {
    // 업데이트 안내
}
```

## Combine

| API | 설명 | 플랫폼 |
| --- | --- | --- |
| `Publisher.main` | 이후 이벤트를 메인 큐에서 전달합니다. | 전체 |
| `Publisher.sink(with:receiveValue:)` | 객체를 약하게 캡처하여 `Never` 실패 Publisher를 구독합니다. | 전체 |
| `Publisher.sink(with:receiveCompletion:receiveValue:)` | 객체를 약하게 캡처하면서 완료와 값 이벤트를 구독합니다. | 전체 |
| `CancellableBag` | `Set<AnyCancellable>` 저장소를 요구하는 프로토콜입니다. | 전체 |
| `KeyboardInfo` | 키보드 높이, 애니메이션 시간 및 곡선을 전달합니다. | iOS |
| `Publishers.keyboardHeightPublisher` | 키보드 프레임 변경에 따라 화면과 겹치는 높이 또는 0을 방출합니다. | iOS |
| `Publishers.keyboardInfoPublisher` | 키보드 높이와 애니메이션 정보를 방출합니다. | iOS |

```swift
final class ViewModel: CancellableBag {
    var cancellables = Set<AnyCancellable>()
}

publisher
    .main
    .sink(with: viewModel) { viewModel, value in
        // viewModel은 약하게 캡처됩니다.
    }
    .store(in: &viewModel.cancellables)
```

## 관련 문서

- [SoyBeanUI](SoyBeanUI.md)
- [SoyBeanUtil](SoyBeanUtil.md)
- [플랫폼 지원](PlatformSupport.md)
