# SoyBean
사이드 프로젝트에서 반복적으로 사용되는 로직을 정의한 모듈.

<br>

## SoyBeanCore
공통되면서 핵심적인 로직을 담고있는 모듈

- Error
 Core 모듈 처리 중 발생되는 에러가 정의된 디렉토리
- Extension
 Foundation 및 Swift 표준 라이브러리의 기존 타입(Date, String, Array ...)을 확장한 extension 구현
- Util
 객체 생성 없이 포맷 변환, 정규식 처리 또는 인코딩 및 디코딩, 클립보드나 외부 앱 접근 등의 유틸리티 static 메소드 구현

<br>

## SoyBeanUI
공통적으로 사용되는 UI 컴포넌트를 담고있는 모듈

- CustomView
 UIKit 또는 SwiftUI 의 뷰를 커스텀한 구현체 또는 지원되지않는 뷰를 구현
- Extension
 UIKit 과 SwiftUI 의 기존 타입(UIView, View ...)를 확장한 extension 구현 test1

