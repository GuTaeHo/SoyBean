//
//  ToastView.swift
//  SoyBean
//
//  Created by 구태호 on 2/26/26.
//

import UIKit

// MARK: - Toast Duration

public enum ToastDuration {
    case short  // 3초
    case long   // 6초

    var seconds: TimeInterval {
        switch self {
        case .short: return 3.0
        case .long: return 6.0
        }
    }
}

// MARK: - Toast Type

public enum ToastType {
    /// 성공/완료 등 긍정적인 피드백 → .success 햅틱
    case positive
    /// 오류/경고 등 부정적인 피드백 → .error 햅틱 + 좌우 흔들림
    case negative
}

// MARK: - ToastView

public final class ToastView: UIView {

    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let blurView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .systemMaterialDark)
        let view = UIVisualEffectView(effect: effect)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Init

    public init(message: String) {
        super.init(frame: .zero)
        label.text = message
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        backgroundColor = .clear

        addSubview(blurView)
        blurView.contentView.addSubview(label)

        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),

            label.topAnchor.constraint(equalTo: blurView.contentView.topAnchor, constant: 12),
            label.bottomAnchor.constraint(equalTo: blurView.contentView.bottomAnchor, constant: -12),
            label.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor, constant: -20),
        ])
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        // 캡슐 형태 (height 절반을 cornerRadius 로)
        layer.cornerRadius = bounds.height / 2
        layer.masksToBounds = true
    }

    // MARK: - Shake Animation

    /// 토스트를 좌우로 흔드는 애니메이션
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.45
        animation.values = [0, -10, 10, -8, 8, -5, 5, 0]
        layer.add(animation, forKey: "shake")
    }
}

// MARK: - ToastKeyboardObserver

/// 키보드 높이를 항상 최신 상태로 유지하는 싱글턴 옵저버
final class ToastKeyboardObserver {

    static let shared = ToastKeyboardObserver()

    /// 현재 키보드가 차지하는 높이 (화면 좌표 기준, 내려가 있으면 0)
    private(set) var keyboardHeight: CGFloat = 0

    private init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChange(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func keyboardWillChange(_ notification: Notification) {
        guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let screenHeight = UIScreen.main.bounds.height
        // 키보드가 화면 밖으로 나간 경우도 0으로 처리
        keyboardHeight = max(0, screenHeight - frame.origin.y)
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        keyboardHeight = 0
    }
}

// MARK: - Toast Presenter (내부 공통 로직)

// TopToastPresenter 인스턴스를 강한 참조로 유지 (dismiss 완료까지 해제 방지)
var activeTopPresenters: [TopToastPresenter] = []

func presentToast(message: String, duration: ToastDuration, isShowTop: Bool, type: ToastType) {
    // 옵저버 첫 호출 시 초기화 보장
    _ = ToastKeyboardObserver.shared

    guard let window = UIApplication.shared.connectedScenes
        .compactMap({ $0 as? UIWindowScene })
        .flatMap({ $0.windows })
        .first(where: { $0.isKeyWindow }) else { return }

    // 햅틱 피드백: positive → success, negative → error
    switch type {
    case .positive:
        HapticManager.shared.start(.notification(.success))
    case .negative:
        HapticManager.shared.start(.notification(.error))
    }

    let horizontalPadding: CGFloat = 32
    let maxWidth = window.bounds.width - horizontalPadding * 2
    let toast = ToastView(message: message)

    if isShowTop {
        // 상단: 위에서 내려오는 애니메이션 + 터치 홀드 + 스와이프 해제
        let presenter = TopToastPresenter(toast: toast, window: window, duration: duration.seconds, type: type)
        activeTopPresenters.append(presenter)
        presenter.present(maxWidth: maxWidth) {
            activeTopPresenters.removeAll { $0 === presenter }
        }
    } else {
        // 중앙: Fade in/out
        // 키보드가 올라와 있으면 키보드 위 영역의 중앙, 아니면 화면 중앙
        let keyboardHeight = ToastKeyboardObserver.shared.keyboardHeight
        let safeTop = window.safeAreaInsets.top
        // 상단 safeArea ~ 키보드 위 사이의 영역 중앙
        let visibleTop = safeTop
        let visibleBottom = window.bounds.height - keyboardHeight
        let visibleCenterY = visibleTop + (visibleBottom - visibleTop) / 2
        let centerYOffset = visibleCenterY - window.bounds.height / 2

        toast.translatesAutoresizingMaskIntoConstraints = false
        toast.alpha = 0
        window.addSubview(toast)

        NSLayoutConstraint.activate([
            toast.centerXAnchor.constraint(equalTo: window.centerXAnchor),
            toast.centerYAnchor.constraint(equalTo: window.centerYAnchor, constant: centerYOffset),
            toast.widthAnchor.constraint(lessThanOrEqualToConstant: maxWidth),
        ])

        window.layoutIfNeeded()

        UIView.animate(withDuration: 0.3) {
            toast.alpha = 1
        } completion: { _ in
            // negative일 때 등장 후 흔들기
            if type == .negative {
                toast.shake()
            }
            UIView.animate(withDuration: 0.3, delay: duration.seconds) {
                toast.alpha = 0
            } completion: { _ in
                toast.removeFromSuperview()
            }
        }
    }
}

// MARK: - TopToastPresenter
// isShowTop = true 일 때 전용: 위에서 내려오는 애니메이션 + 터치 홀드 + 위로 스와이프 해제

final class TopToastPresenter: NSObject, UIGestureRecognizerDelegate {

    private let toast: ToastView
    private let window: UIWindow
    private let duration: TimeInterval
    private let type: ToastType
    private var onDismissed: (() -> Void)? = nil

    private var topConstraint: NSLayoutConstraint!

    /// 토스트가 완전히 들어왔을 때의 top 상수
    private var shownTopConstant: CGFloat = 0
    /// 화면 위로 완전히 숨겨졌을 때의 top 상수
    private var hiddenTopConstant: CGFloat = -200

    /// 자동 dismiss 타이머
    private var dismissTimer: Timer?
    /// 손가락이 닿아 있는지 여부
    private var isTouching = false
    /// 타이머가 만료됐지만 터치 중이어서 대기 중인지
    private var pendingDismiss = false

    init(toast: ToastView, window: UIWindow, duration: TimeInterval, type: ToastType) {
        self.toast = toast
        self.window = window
        self.duration = duration
        self.type = type
    }

    func present(maxWidth: CGFloat, onDismissed: @escaping () -> Void) {
        self.onDismissed = onDismissed

        toast.translatesAutoresizingMaskIntoConstraints = false
        window.addSubview(toast)

        topConstraint = toast.topAnchor.constraint(equalTo: window.topAnchor, constant: hiddenTopConstant)

        NSLayoutConstraint.activate([
            toast.centerXAnchor.constraint(equalTo: window.centerXAnchor),
            topConstraint,
            toast.widthAnchor.constraint(lessThanOrEqualToConstant: maxWidth),
        ])

        // 실제 높이를 알아야 safeArea + 여백 계산 가능하므로 레이아웃 먼저 수행
        window.layoutIfNeeded()

        let safeTop = window.safeAreaInsets.top
        shownTopConstant = safeTop + 16
        hiddenTopConstant = -(toast.bounds.height + safeTop + 32)
        topConstraint.constant = hiddenTopConstant
        window.layoutIfNeeded()

        attachGestures()

        // 위에서 내려오는 spring 애니메이션으로 등장
        topConstraint.constant = shownTopConstant
        UIView.animate(
            withDuration: 0.45,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.5
        ) {
            self.window.layoutIfNeeded()
        } completion: { _ in
            // negative일 때 등장 후 흔들기
            if self.type == .negative {
                self.toast.shake()
            }
            self.scheduleDismiss()
        }
    }

    // MARK: - Timer

    private func scheduleDismiss() {
        dismissTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
            guard let self else { return }
            if self.isTouching {
                self.pendingDismiss = true
            } else {
                self.dismiss()
            }
        }
    }

    private func cancelTimer() {
        dismissTimer?.invalidate()
        dismissTimer = nil
    }

    // MARK: - Dismiss

    func dismiss() {
        cancelTimer()
        topConstraint.constant = hiddenTopConstant
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) {
            self.window.layoutIfNeeded()
        } completion: { _ in
            self.toast.removeFromSuperview()
            self.onDismissed?()
            self.onDismissed = nil
        }
    }

    // MARK: - Gestures

    private func attachGestures() {
        // 롱프레스(터치 홀드) - minimumPressDuration 0 으로 설정해 일반 터치도 감지
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPress.minimumPressDuration = 0
        longPress.delegate = self
        toast.addGestureRecognizer(longPress)

        // 위로 스와이프 해제
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pan.delegate = self
        toast.addGestureRecognizer(pan)
    }

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            isTouching = true
            cancelTimer()
        case .ended, .cancelled, .failed:
            isTouching = false
            if pendingDismiss {
                pendingDismiss = false
                dismiss()
            } else {
                // 터치가 끝났으니 duration 부터 다시 타이머
                scheduleDismiss()
            }
        default:
            break
        }
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: window)

        switch gesture.state {
        case .changed:
            // 위쪽 방향 드래그만 반영 (아래로는 저항)
            let offset = min(translation.y, 0)
            topConstraint.constant = shownTopConstant + offset
            window.layoutIfNeeded()

        case .ended, .cancelled:
            let velocity = gesture.velocity(in: window)
            let movedUp = topConstraint.constant < shownTopConstant - 30
            let fastUp = velocity.y < -300

            if movedUp || fastUp {
                dismiss()
            } else {
                // 제자리로 복귀
                topConstraint.constant = shownTopConstant
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
                    self.window.layoutIfNeeded()
                }
            }
        default:
            break
        }
    }

    // 두 제스처가 동시에 인식되도록 허용
    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool { true }
}

// MARK: - UIView Extension

extension UIView {

    /// 토스트 메시지를 현재 UIWindow 위에 표시합니다.
    /// - Parameters:
    ///   - message: 표시할 메시지
    ///   - duration: 표시 시간 (.short = 3초, .long = 6초), 기본값: .short
    ///   - isShowTop: true면 상단 표시, false면 화면 세로 중앙 표시, 기본값: false
    ///   - type: 토스트 유형 (.positive = 성공 햅틱, .negative = 에러 햅틱 + 흔들림), 기본값: .positive
    public func sbShowToast(message: String, duration: ToastDuration = .short, isShowTop: Bool = false, type: ToastType = .positive) {
        presentToast(message: message, duration: duration, isShowTop: isShowTop, type: type)
    }
}

// MARK: - UIViewController Extension

extension UIViewController {

    /// 토스트 메시지를 현재 UIWindow 위에 표시합니다.
    /// - Parameters:
    ///   - message: 표시할 메시지
    ///   - duration: 표시 시간 (.short = 3초, .long = 6초), 기본값: .short
    ///   - isShowTop: true면 상단 표시, false면 화면 세로 중앙 표시, 기본값: false
    ///   - type: 토스트 유형 (.positive = 성공 햅틱, .negative = 에러 햅틱 + 흔들림), 기본값: .positive
    public func sbShowToast(message: String, duration: ToastDuration = .short, isShowTop: Bool = false, type: ToastType = .positive) {
        presentToast(message: message, duration: duration, isShowTop: isShowTop, type: type)
    }
}

// MARK: - SwiftUI View Extension

import SwiftUI

extension View {

    /// 토스트 메시지를 현재 UIWindow 위에 표시합니다.
    /// - Parameters:
    ///   - message: 표시할 메시지
    ///   - duration: 표시 시간 (.short = 3초, .long = 6초), 기본값: .short
    ///   - isShowTop: true면 상단 표시, false면 화면 세로 중앙 표시, 기본값: false
    ///   - type: 토스트 유형 (.positive = 성공 햅틱, .negative = 에러 햅틱 + 흔들림), 기본값: .positive
    public func sbShowToast(message: String, duration: ToastDuration = .short, isShowTop: Bool = false, type: ToastType = .positive) {
        presentToast(message: message, duration: duration, isShowTop: isShowTop, type: type)
    }
}
