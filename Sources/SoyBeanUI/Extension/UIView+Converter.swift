import UIKit

public extension UIView {
    /// 뷰의 프레임 원점 좌표를 지정된 타겟 뷰의 좌표계로 변환합니다.
    ///
    /// - Parameter targetView: 좌표계를 변환할 대상 뷰.
    /// - Returns: `targetView`의 좌표계로 변환된 뷰의 원점 좌표를 나타내는 `CGPoint`.
    func convert(to targetView: UIView) -> CGPoint {
        self.convert(self.frame.origin, to: targetView)
    }
}
