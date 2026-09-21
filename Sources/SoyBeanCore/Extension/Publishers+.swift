//
//  Publishers+.swift
//  SoyBean
//
//  Created by 구태호 on 2/23/26.
//

// Keyboard notifications and UIKit animation options are only available on iOS.
#if os(iOS)
import Combine
import UIKit


public struct KeyboardInfo {
    public let height: CGFloat
    public let duration: Double
    public let curve: UIView.AnimationOptions

    public init(height: CGFloat, duration: Double, curve: UIView.AnimationOptions) {
        self.height = height
        self.duration = duration
        self.curve = curve
    }
}

public extension Publishers {
    /// 키보드 높이를 방출하는 퍼블리셔.
    ///
    /// # 사용 예시
    /// ```swift
    /// KeyboardObserver.keyboardHeightPublisher
    ///     .sink { height in
    ///         self.bottomConstraint.constant = height
    ///         self.view.layoutIfNeeded()
    ///     }
    ///     .store(in: &cancellables)
    /// ```
    static var keyboardHeightPublisher: AnyPublisher<CGFloat, Never> {
        let willChangeFrame = NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)
            .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
            .map { frame in
                max(0, UIScreen.main.bounds.maxY - frame.minY)
            }

        let willHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }

        return Publishers.Merge(willChangeFrame, willHide)
            .eraseToAnyPublisher()
    }
    
    /// 키보드 등장/사라짐 이벤트를 통합해서 방출하는 Publisher///
    ///
    /// # 사용 예시
    /// ```swift
    /// KeyboardObserver.keyboardInfoPublisher
    ///     .sink { keyboardInfo in
    ///         UIView.animate(withDuration: keyboardInfo.duration,
    ///                        delay: 0,
    ///                        options: keyboardInfo.curve) {
    ///             self.bottomConstraint.constant = keyboardInfo.height
    ///             self.view.layoutIfNeeded()
    ///         }
    ///     }
    ///     .store(in: &cancellables)
    /// ```
    static var keyboardInfoPublisher: AnyPublisher<KeyboardInfo, Never> {
        let willChangeFrame = NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)
            .compactMap { notification -> KeyboardInfo? in
                guard
                    let userInfo = notification.userInfo,
                    let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
                    let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
                    let curveValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
                else { return nil }

                return KeyboardInfo(
                    height: max(0, UIScreen.main.bounds.maxY - frame.minY),
                    duration: duration,
                    curve: UIView.AnimationOptions(rawValue: curveValue << 16)
                )
            }

        let willHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .compactMap { notification -> KeyboardInfo? in
                guard
                    let userInfo = notification.userInfo,
                    let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
                    let curveValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
                else { return nil }

                return KeyboardInfo(
                    height: 0,
                    duration: duration,
                    curve: UIView.AnimationOptions(rawValue: curveValue << 16)
                )
            }

        return Publishers.Merge(willChangeFrame, willHide)
            .eraseToAnyPublisher()
    }
}
#endif
