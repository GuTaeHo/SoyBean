# SoyBean
사이드 프로젝트에서 반복적으로 사용되는 로직을 Swift Package 형태로 제공


<br>
<br>

## SoyBeanCore
공통되면서 핵심적인 로직을 담고있는 모듈

<br>

- Error  
 Core 모듈 처리 중 발생되는 에러가 정의된 디렉토리
- Extension  
 Foundation 및 Swift 표준 라이브러리의 기존 타입(Date, String, Array ...)을 확장한 extension 구현
- Manager
 Haptic 및 Push Notification 등 앱 전체에서 사용되는 싱글톤 매니저 구현


<br>
<br>

## SoyBeanUI
공통적으로 사용되는 UI 컴포넌트를 담고있는 모듈

<br>

- CustomView  
 UIKit 또는 SwiftUI 의 뷰를 커스텀한 구현체 또는 지원되지않는 뷰 구현
- Extension  
 UIKit 과 SwiftUI 의 기존 타입(UIView, View ...)를 확장한 extension
 
 
<br>
<br>
 
## SoyBeanUtil
포맷 변환, 정규식 체크, 클립보드 등 유용한 유틸 클래스 구현

<br>

- Util  
 날짜 및 시간 포맷 변환, 정규식 처리 또는 인코딩 및 디코딩, 클립보드나 외부 앱 접근 등의 유틸리티 정적 메소드 구현
