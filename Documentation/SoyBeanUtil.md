# SoyBeanUtil

`SoyBeanUtil`은 포맷, 유효성 검사, JWT·Base64URL 디코딩, 저장소, multipart 본문 및 플랫폼 앱 유틸리티를 제공합니다.

정확한 매개변수, 반환값 및 실패 조건은 각 공개 선언의 `///` 문서 주석을 기준으로 합니다.

## 날짜 포맷

| API | 설명 | 플랫폼 |
| --- | --- | --- |
| `FormatUtil.DateFormat.MM_Dot_dd` | `MM.dd` 포맷을 선택합니다. | 전체 |
| `FormatUtil.DateFormat.yy_Dot_MM_Dot_dd` | `yy.MM.dd` 포맷을 선택합니다. | 전체 |
| `FormatUtil.DateFormat.custom(_:)` | 사용자 지정 날짜 포맷을 선택합니다. | 전체 |
| `FormatUtil.currentDate()` | 현재 시각을 `yyyy-MM-dd HH:mm:ss` 문자열로 반환합니다. | 전체 |
| `FormatUtil.formatDate(_:to:)` | 기본 날짜 문자열을 선택한 포맷으로 변환합니다. | 전체 |

변환할 수 없는 날짜는 `SoyBeanError.dateFormattingError`를 던집니다.

## 정규식 검증

| `RegExpUtil.RegCase` | 형식 |
| --- | --- |
| `.email` | 일반 이메일 주소 |
| `.password(range:)` | 지정 길이 안에서 영문자와 숫자를 각각 하나 이상 포함하는 문자열 |
| `.birthday` | 실제 날짜로 변환 가능한 `yyyyMMdd` 문자열 |

`RegExpUtil.evaluate(type:compareWith:)`로 값을 검사합니다.

```swift
let isPassword = RegExpUtil.evaluate(
    type: .password(range: 8...20),
    compareWith: "password123"
)
```

## JWT와 Base64URL

| API | 설명 | 플랫폼 |
| --- | --- | --- |
| `DecodeUtil.jwtDecode(jwtToken:)` | 세 부분으로 구성된 JWT의 payload를 딕셔너리로 반환합니다. 잘못된 형식은 빈 딕셔너리를 반환합니다. | 전체 |
| `DecodeUtil.decodeJWTpayload(_:)` | Base64URL payload를 JSON 딕셔너리로 변환합니다. | 전체 |
| `DecodeUtil.base64UrlDecode(_:)` | Base64URL 문자열을 `Data`로 변환합니다. | 전체 |

이 API는 payload 디코딩만 수행하며 JWT 서명이나 신뢰성을 검증하지 않습니다.

## Keychain

모든 값은 `Codable`을 준수해야 합니다. `groupAt`에는 Keychain Sharing이 활성화된 타깃의 Access Group을 전달할 수 있습니다.

| API | 설명 |
| --- | --- |
| `KeychainManager.shared` | 공용 Keychain 관리자입니다. |
| `save(_:forKey:groupAt:)` | 값을 JSON으로 인코딩하여 저장합니다. 기존 키는 삭제 후 다시 저장합니다. |
| `load(_:forKey:groupAt:)` | 저장된 값을 지정한 `Codable` 타입으로 디코딩합니다. |
| `update(_:forKey:groupAt:)` | 기존 항목의 값을 수정합니다. |
| `delete(forKey:groupAt:)` | 지정한 키를 삭제합니다. |
| `loadAll(groupAt:)` | Generic Password 항목을 문자열 딕셔너리로 조회합니다. 값은 저장된 JSON 데이터의 UTF-8 표현입니다. |
| `deleteAll(groupAt:)` | 지정 그룹의 Keychain 항목을 클래스별로 일괄 삭제합니다. |

Keychain API는 iOS, macOS 및 watchOS에서 사용할 수 있습니다.

## UserDefaults 마이그레이션

### Codable 저장

| API | 설명 |
| --- | --- |
| `UserDefaults.save(_:forKey:encoder:)` | `Codable` 값을 JSON 데이터로 저장하며 `nil`이면 키를 삭제합니다. |
| `UserDefaults.load(_:forKey:decoder:)` | JSON 데이터로 저장된 값을 지정한 타입으로 불러옵니다. |
| Property List encoder·decoder overload | 같은 API 이름으로 Property List 데이터도 저장하고 불러옵니다. |

```swift
try UserDefaults.standard.save(profile, forKey: "profile")
let profile = try UserDefaults.standard.load(Profile.self, forKey: "profile")
```

### 저장소 마이그레이션

`UserDefaultsMigratable`은 다음 항목을 요구합니다.

| 요구 사항 | 설명 |
| --- | --- |
| `KeyType` | `String` raw value와 `CaseIterable`을 지원하는 키 타입입니다. |
| `allKeys` | 마이그레이션할 모든 키입니다. |
| `standard` | 원본 또는 대상 `UserDefaults` 저장소입니다. |
| `migrate(to:)` | 같은 키의 값을 대상 저장소로 복사합니다. |

대상에 없는 키를 검사하거나 값을 삭제하지는 않습니다.

## Multipart 요청 본문

`MultipartFormData`는 Foundation만 사용하여 문자열과 파일 파트를 조립합니다. Alamofire 같은 네트워크 패키지의 요청·응답 처리는 건드리지 않으며, 필요한 경우 만들어진 `Data`만 해당 네트워크 계층에 전달할 수 있습니다.

```swift
var formData = MultipartFormData()
formData.append(name: "title", value: "프로필")
formData.append(
    name: "image",
    fileName: "profile.jpg",
    mimeType: "image/jpeg",
    data: imageData
)

var request = URLRequest(url: uploadURL)
formData.apply(to: &request)
```

## 알림 첨부 다운로드

`NotificationAttachmentDownloader`는 iOS에서 원격 이미지를 내려받아 `UNNotificationAttachment`로 변환합니다. HTTP 성공 상태, 이미지 형식과 최대 파일 크기를 확인하며 기본 제한은 10MB, 기본 timeout은 15초입니다.

```swift
let downloader = NotificationAttachmentDownloader()
downloader.attachment(for: imageURL) { attachment in
    bestAttemptContent.attachments = attachment.map { [$0] } ?? []
    contentHandler(bestAttemptContent)
}
```

Notification Service Extension의 제한 시간이 끝나기 전 `cancel()`로 진행 중인 요청을 취소할 수 있습니다.

## 앱과 클립보드

### iOS

`AppUtil`은 `UIApplication`과 `UIPasteboard`를 사용하므로 iOS 앱에서만 제공되며 App Extension에서는 사용할 수 없습니다. `NotificationAttachmentDownloader`를 포함한 나머지 호환 API는 Notification Service Extension에서 사용할 수 있습니다.

| API | 설명 |
| --- | --- |
| `AppUtil.exitApp()` | 앱을 suspend한 뒤 프로세스를 종료합니다. App Store 정책을 고려해 사용해야 합니다. |
| `AppUtil.openSettings()` | 현재 앱의 시스템 설정 화면을 엽니다. |
| `AppUtil.openSafari(url:)` | URL을 외부 앱으로 열며 실패하면 `SoyBeanError`를 던집니다. |
| `AppUtil.openAppStore(appStoreUrl:completion:)` | App Store URL을 열고 completion을 호출합니다. |
| `AppUtil.clipboard` | 문자열 클립보드를 읽거나 씁니다. |

### macOS

| API | 설명 |
| --- | --- |
| `Util.clipboard` | `NSPasteboard`의 문자열을 읽거나 씁니다. |

watchOS에서는 앱 열기 및 클립보드 API가 제공되지 않습니다.

## 관련 문서

- [SoyBeanCore](SoyBeanCore.md)
- [SoyBeanUI](SoyBeanUI.md)
- [플랫폼 지원](PlatformSupport.md)
