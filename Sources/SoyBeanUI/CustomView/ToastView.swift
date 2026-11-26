//
//  ToastView.swift
//  SoyBean
//
//  Created by 구태호 on 2/26/26.
//

import Foundation

// MARK: - Toast Duration

/// 토스트가 나타난 뒤 자동으로 닫히기까지의 시간입니다.
public enum ToastDuration {
    /// 3초 동안 표시합니다.
    case short
    /// 6초 동안 표시합니다.
    case long
    /// 지정한 초 동안 표시합니다. 음수나 유한하지 않은 값은 3초를 적용합니다.
    case custom(TimeInterval)
    /// 토스트의 닫기 버튼을 누를 때까지 표시합니다.
    case infinity

    var seconds: TimeInterval? {
        switch self {
        case .short: return 3
        case .long: return 6
        case .custom(let seconds): return seconds.isFinite && seconds >= 0 ? seconds : Self.short.seconds
        case .infinity: return nil
        }
    }
}

/// 토스트의 배경과 글자색을 결정합니다.
public enum ToastTheme {
    /// 밝은 배경과 어두운 글자를 사용합니다.
    case light
    /// 어두운 배경과 밝은 글자를 사용합니다.
    case dark
    /// 현재 화면이 다크 모드면 라이트 테마, 라이트 모드면 다크 테마를 사용합니다.
    case system

    func usesLightAppearance(systemIsDark: Bool) -> Bool {
        switch self {
        case .light: return true
        case .dark: return false
        case .system: return systemIsDark
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

#if os(iOS) || os(macOS)
private enum ToastLayout {
    static let cornerRadius: CGFloat = 26
    static let minimumHeight: CGFloat = 52
    static let textVerticalInset: CGFloat = 12
    static let textHorizontalInset: CGFloat = 20
    static let windowHorizontalInset: CGFloat = 32
    static let tabletMaximumWidth: CGFloat = 400
    static let closeIconSize: CGFloat = 20
    static let closeTargetSize: CGFloat = 36
    static let closeTrailingInset: CGFloat = 8
    static let closeLabelSpacing: CGFloat = 6
}
#endif

#if os(iOS)
import UIKit

// MARK: - ToastView

public final class ToastView: UIView {

    @usableFromInline
    static var defaultFont: UIFont {
        .systemFont(ofSize: 14, weight: .medium)
    }

    private let theme: ToastTheme
    private var dismissAction: (() -> Void)?
    private var labelTrailingConstraint: NSLayoutConstraint?
    private var closeButton: UIButton?
    fileprivate var topPresenter: TopToastPresenter?

    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let blurView: UIVisualEffectView = {
        let view = UIVisualEffectView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Init

    /// 기본 폰트로 메시지를 표시하는 토스트 뷰를 생성합니다.
    public convenience init(message: String) {
        self.init(message: message, font: ToastView.defaultFont)
    }

    /// 지정된 폰트로 메시지를 표시하는 토스트 뷰를 생성합니다.
    public convenience init(message: String, font: UIFont = ToastView.defaultFont) {
        self.init(message: message, font: font, theme: .system)
    }

    /// 지정된 폰트와 테마로 토스트 뷰를 생성합니다.
    public init(
        message: String,
        font: UIFont = ToastView.defaultFont,
        theme: ToastTheme = .system
    ) {
        self.theme = theme
        super.init(frame: .zero)
        label.text = message
        label.font = font
        setup()
        applyTheme()
        if #available(iOS 17.0, *), theme == .system {
            registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (view: ToastView, _) in
                view.applyTheme()
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        backgroundColor = .clear
        layer.cornerRadius = ToastLayout.cornerRadius
        layer.masksToBounds = true

        addSubview(blurView)
        blurView.contentView.addSubview(label)

        let textSurface = blurView.contentView
        let labelTrailingConstraint = label.trailingAnchor.constraint(
            equalTo: textSurface.trailingAnchor,
            constant: -ToastLayout.textHorizontalInset
        )
        let preferredLabelTop = label.topAnchor.constraint(
            equalTo: textSurface.topAnchor,
            constant: ToastLayout.textVerticalInset
        )
        // 최소 높이로 카드가 확장되면 라벨 자체의 높이를 유지한다.
        preferredLabelTop.priority = .fittingSizeLevel
        self.labelTrailingConstraint = labelTrailingConstraint
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),

            heightAnchor.constraint(greaterThanOrEqualToConstant: ToastLayout.minimumHeight),
            label.centerYAnchor.constraint(equalTo: textSurface.centerYAnchor),
            label.topAnchor.constraint(greaterThanOrEqualTo: textSurface.topAnchor, constant: ToastLayout.textVerticalInset),
            preferredLabelTop,
            label.leadingAnchor.constraint(equalTo: textSurface.leadingAnchor, constant: ToastLayout.textHorizontalInset),
            labelTrailingConstraint,
        ])
    }

    public override func didMoveToWindow() {
        super.didMoveToWindow()
        if window == nil {
            topPresenter = nil
        }
        applyTheme()
    }

    @available(iOS, introduced: 8.0, deprecated: 17.0)
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if theme == .system, traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
            applyTheme()
        }
    }

    private func applyTheme() {
        let usesLightAppearance = theme.usesLightAppearance(systemIsDark: traitCollection.userInterfaceStyle == .dark)
        blurView.effect = UIBlurEffect(style: usesLightAppearance ? .systemMaterialLight : .systemMaterialDark)
        label.textColor = usesLightAppearance ? .black : .white
        closeButton?.tintColor = label.textColor
    }

    fileprivate func enableManualDismiss(_ action: @escaping () -> Void) {
        dismissAction = action
        let button = UIButton(type: .system)
        let configuration = UIImage.SymbolConfiguration(pointSize: ToastLayout.closeIconSize, weight: .semibold)
        button.setImage(UIImage(systemName: "xmark", withConfiguration: configuration), for: .normal)
        button.accessibilityLabel = "토스트 닫기"
        button.tintColor = label.textColor
        button.addTarget(self, action: #selector(dismissManually), for: .touchUpInside)
        closeButton = button
        button.translatesAutoresizingMaskIntoConstraints = false
        let textSurface = blurView.contentView
        textSurface.addSubview(button)

        let font = label.font ?? Self.defaultFont
        let firstLineCenterOffset = -(font.ascender + font.descender) / 2
        labelTrailingConstraint?.isActive = false
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: ToastLayout.closeTargetSize),
            button.heightAnchor.constraint(equalTo: button.widthAnchor),
            button.centerYAnchor.constraint(equalTo: label.firstBaselineAnchor, constant: firstLineCenterOffset),
            button.topAnchor.constraint(greaterThanOrEqualTo: textSurface.topAnchor),
            button.bottomAnchor.constraint(lessThanOrEqualTo: textSurface.bottomAnchor),
            button.trailingAnchor.constraint(equalTo: textSurface.trailingAnchor, constant: -ToastLayout.closeTrailingInset),
            label.trailingAnchor.constraint(equalTo: button.leadingAnchor, constant: -ToastLayout.closeLabelSpacing),
        ])
    }

    @objc private func dismissManually() {
        let action = dismissAction
        dismissAction = nil
        action?()
    }

    // MARK: - Shake Animation

    /// 토스트를 좌우로 흔드는 애니메이션 (흔들림 시작 시점에 error 햅틱 발생)
    func shake() {
        HapticManager.shared.start(.notification(.error))
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

private func presentToast(
    message: String,
    duration: ToastDuration,
    isShowTop: Bool,
    type: ToastType,
    font: UIFont,
    theme: ToastTheme
) {
    // 옵저버 첫 호출 시 초기화 보장
    _ = ToastKeyboardObserver.shared

    guard let window = UIApplication.shared.connectedScenes
        .compactMap({ $0 as? UIWindowScene })
        .flatMap({ $0.windows })
        .first(where: { $0.isKeyWindow }) else { return }

    let toast = ToastView(message: message, font: font, theme: theme)
    var widthConstraints = [
        toast.widthAnchor.constraint(
            lessThanOrEqualTo: window.safeAreaLayoutGuide.widthAnchor,
            constant: -2 * ToastLayout.windowHorizontalInset
        ),
    ]
    if window.traitCollection.userInterfaceIdiom == .pad {
        widthConstraints.append(toast.widthAnchor.constraint(lessThanOrEqualToConstant: ToastLayout.tabletMaximumWidth))
    }

    if isShowTop {
        // 상단: 위에서 내려오는 애니메이션 + 터치 홀드 + 스와이프 해제
        let presenter = TopToastPresenter(toast: toast, duration: duration.seconds, type: type)
        toast.topPresenter = presenter
        presenter.present(in: window, widthConstraints: widthConstraints)
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
        ] + widthConstraints)

        if duration.seconds == nil {
            toast.enableManualDismiss { [weak toast] in
                guard let toast else { return }
                fadeOut(toast, delay: 0)
            }
        }

        window.layoutIfNeeded()

        UIView.animate(withDuration: 0.3) {
            toast.alpha = 1
        } completion: { finished in
            guard finished, toast.superview != nil else { return }
            if type == .negative {
                toast.shake()
            } else {
                HapticManager.shared.start(.notification(.success))
            }
            if let seconds = duration.seconds {
                fadeOut(toast, delay: seconds)
            }
        }
    }
}

private func fadeOut(_ toast: ToastView, delay: TimeInterval) {
    UIView.animate(withDuration: 0.3, delay: delay, options: [.beginFromCurrentState]) {
        toast.alpha = 0
    } completion: { _ in
        toast.removeFromSuperview()
    }
}

// MARK: - TopToastPresenter
// isShowTop = true 일 때 전용: 위에서 내려오는 애니메이션 + 터치 홀드 + 위로 스와이프 해제

fileprivate final class TopToastPresenter: NSObject, UIGestureRecognizerDelegate {

    private weak var toast: ToastView?
    private let duration: TimeInterval?
    private let type: ToastType
    private var topConstraint: NSLayoutConstraint?
    private var isDismissing = false

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

    init(toast: ToastView, duration: TimeInterval?, type: ToastType) {
        self.toast = toast
        self.duration = duration
        self.type = type
    }

    deinit {
        dismissTimer?.invalidate()
    }

    func present(in window: UIWindow, widthConstraints: [NSLayoutConstraint]) {
        guard let toast else { return }

        toast.translatesAutoresizingMaskIntoConstraints = false
        window.addSubview(toast)

        let topConstraint = toast.topAnchor.constraint(equalTo: window.topAnchor, constant: hiddenTopConstant)
        self.topConstraint = topConstraint

        NSLayoutConstraint.activate([
            toast.centerXAnchor.constraint(equalTo: window.centerXAnchor),
            topConstraint,
        ] + widthConstraints)

        attachGestures(to: toast)

        // 토스트의 최종 높이로 화면 밖 시작 위치를 계산한다.
        window.layoutIfNeeded()

        let safeTop = window.safeAreaInsets.top
        shownTopConstant = safeTop + 16
        hiddenTopConstant = -(toast.bounds.height + safeTop + 32)
        topConstraint.constant = hiddenTopConstant
        window.layoutIfNeeded()

        // 위에서 내려오는 spring 애니메이션으로 등장
        topConstraint.constant = shownTopConstant
        UIView.animate(
            withDuration: 0.45,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.5
        ) {
            window.layoutIfNeeded()
        } completion: { [weak self] _ in
            guard let self, !self.isDismissing, let toast = self.toast, toast.window != nil else { return }
            if self.type == .negative {
                toast.shake()
            } else {
                HapticManager.shared.start(.notification(.success))
            }
            self.scheduleDismiss()
        }
    }

    // MARK: - Timer

    private func scheduleDismiss() {
        guard let duration, !isDismissing else { return }
        cancelTimer()
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

    private func dismiss() {
        guard !isDismissing, let toast, let window = toast.window else { return }
        isDismissing = true
        cancelTimer()
        topConstraint?.constant = hiddenTopConstant
        UIView.animate(withDuration: 0.3, delay: 0, options: [.beginFromCurrentState, .curveEaseIn]) {
            window.layoutIfNeeded()
        } completion: { _ in
            toast.removeFromSuperview()
        }
    }

    // MARK: - Gestures

    private func attachGestures(to toast: ToastView) {
        if duration == nil {
            toast.enableManualDismiss { [weak self] in self?.dismiss() }
        } else {
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
            longPress.minimumPressDuration = 0
            longPress.delegate = self
            toast.addGestureRecognizer(longPress)
        }

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
        guard !isDismissing, let topConstraint, let window = toast?.window else { return }
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
                    window.layoutIfNeeded()
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

    /// 현재 윈도우에 기본 폰트로 토스트를 표시합니다.
    public func sbShowToast(
        message: String,
        duration: ToastDuration = .short,
        isShowTop: Bool = false,
        type: ToastType = .positive
    ) {
        sbShowToast(message: message, duration: duration, isShowTop: isShowTop, type: type, font: ToastView.defaultFont)
    }

    /// 토스트 메시지를 현재 UIWindow 위에 표시합니다.
    /// - Parameters:
    ///   - message: 표시할 메시지
    ///   - duration: 표시 시간 (.short = 3초, .long = 6초), 기본값: .short
    ///   - isShowTop: true면 상단 표시, false면 화면 세로 중앙 표시, 기본값: false
    ///   - type: 토스트 유형 (.positive = 성공 햅틱, .negative = 에러 햅틱 + 흔들림), 기본값: .positive
    ///   - font: 메시지에 사용할 폰트. 기본값은 14pt Medium 시스템 폰트입니다.
    public func sbShowToast(
        message: String,
        duration: ToastDuration = .short,
        isShowTop: Bool = false,
        type: ToastType = .positive,
        font: UIFont = ToastView.defaultFont
    ) {
        sbShowToast(message: message, duration: duration, isShowTop: isShowTop, type: type, font: font, theme: .system)
    }

    /// 지정된 테마로 현재 윈도우에 토스트를 표시합니다.
    /// - Parameters:
    ///   - theme: 배경과 글자색을 결정합니다. 기본값은 시스템 설정과 반대 테마를 적용하는 `.system`입니다.
    public func sbShowToast(
        message: String,
        duration: ToastDuration = .short,
        isShowTop: Bool = false,
        type: ToastType = .positive,
        font: UIFont = ToastView.defaultFont,
        theme: ToastTheme = .system
    ) {
        presentToast(message: message, duration: duration, isShowTop: isShowTop, type: type, font: font, theme: theme)
    }
}

// MARK: - UIViewController Extension

extension UIViewController {

    /// 현재 윈도우에 기본 폰트로 토스트를 표시합니다.
    public func sbShowToast(
        message: String,
        duration: ToastDuration = .short,
        isShowTop: Bool = false,
        type: ToastType = .positive
    ) {
        sbShowToast(message: message, duration: duration, isShowTop: isShowTop, type: type, font: ToastView.defaultFont)
    }

    /// 토스트 메시지를 현재 UIWindow 위에 표시합니다.
    /// - Parameters:
    ///   - message: 표시할 메시지
    ///   - duration: 표시 시간 (.short = 3초, .long = 6초), 기본값: .short
    ///   - isShowTop: true면 상단 표시, false면 화면 세로 중앙 표시, 기본값: false
    ///   - type: 토스트 유형 (.positive = 성공 햅틱, .negative = 에러 햅틱 + 흔들림), 기본값: .positive
    ///   - font: 메시지에 사용할 폰트. 기본값은 14pt Medium 시스템 폰트입니다.
    public func sbShowToast(
        message: String,
        duration: ToastDuration = .short,
        isShowTop: Bool = false,
        type: ToastType = .positive,
        font: UIFont = ToastView.defaultFont
    ) {
        sbShowToast(message: message, duration: duration, isShowTop: isShowTop, type: type, font: font, theme: .system)
    }

    /// 지정된 테마로 현재 윈도우에 토스트를 표시합니다.
    /// - Parameters:
    ///   - theme: 배경과 글자색을 결정합니다. 기본값은 시스템 설정과 반대 테마를 적용하는 `.system`입니다.
    public func sbShowToast(
        message: String,
        duration: ToastDuration = .short,
        isShowTop: Bool = false,
        type: ToastType = .positive,
        font: UIFont = ToastView.defaultFont,
        theme: ToastTheme = .system
    ) {
        presentToast(message: message, duration: duration, isShowTop: isShowTop, type: type, font: font, theme: theme)
    }
}

// MARK: - SwiftUI View Extension

import SwiftUI

extension View {

    /// 현재 윈도우에 기본 폰트로 토스트를 표시합니다.
    public func sbShowToast(
        message: String,
        duration: ToastDuration = .short,
        isShowTop: Bool = false,
        type: ToastType = .positive
    ) {
        sbShowToast(message: message, duration: duration, isShowTop: isShowTop, type: type, font: ToastView.defaultFont)
    }

    /// 토스트 메시지를 현재 UIWindow 위에 표시합니다.
    /// - Parameters:
    ///   - message: 표시할 메시지
    ///   - duration: 표시 시간 (.short = 3초, .long = 6초), 기본값: .short
    ///   - isShowTop: true면 상단 표시, false면 화면 세로 중앙 표시, 기본값: false
    ///   - type: 토스트 유형 (.positive = 성공 햅틱, .negative = 에러 햅틱 + 흔들림), 기본값: .positive
    ///   - font: 메시지에 사용할 폰트. 기본값은 14pt Medium 시스템 폰트입니다.
    public func sbShowToast(
        message: String,
        duration: ToastDuration = .short,
        isShowTop: Bool = false,
        type: ToastType = .positive,
        font: UIFont = ToastView.defaultFont
    ) {
        sbShowToast(message: message, duration: duration, isShowTop: isShowTop, type: type, font: font, theme: .system)
    }

    /// 지정된 테마로 현재 윈도우에 토스트를 표시합니다.
    /// - Parameters:
    ///   - theme: 배경과 글자색을 결정합니다. 기본값은 시스템 설정과 반대 테마를 적용하는 `.system`입니다.
    public func sbShowToast(
        message: String,
        duration: ToastDuration = .short,
        isShowTop: Bool = false,
        type: ToastType = .positive,
        font: UIFont = ToastView.defaultFont,
        theme: ToastTheme = .system
    ) {
        presentToast(message: message, duration: duration, isShowTop: isShowTop, type: type, font: font, theme: theme)
    }
}
#elseif os(macOS)
import AppKit
import SwiftUI

private final class ToastCloseButton: NSButton {
    override var alignmentRectInsets: NSEdgeInsets {
        NSEdgeInsets()
    }
}

// MARK: - ToastView

public final class ToastView: NSView {

    @usableFromInline
    static var defaultFont: NSFont {
        .systemFont(ofSize: 14, weight: .medium)
    }

    private let theme: ToastTheme
    private var dismissAction: (() -> Void)?
    private var labelTrailingConstraint: NSLayoutConstraint?
    private var closeButton: NSButton?
    fileprivate var presenter: MacToastPresenter?

    private let label: NSTextField = {
        let label = NSTextField(labelWithString: "")
        label.alignment = .center
        // 긴 문구가 창 크기를 확대하기 전에 라벨을 가용 너비로 압축한다.
        label.setContentCompressionResistancePriority(.init(251), for: .horizontal)
        label.maximumNumberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let blurView: NSVisualEffectView = {
        let view = NSVisualEffectView()
        view.material = .hudWindow
        view.blendingMode = .withinWindow
        view.state = .active
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    /// 기본 폰트로 메시지를 표시하는 토스트 뷰를 생성합니다.
    public convenience init(message: String) {
        self.init(message: message, font: ToastView.defaultFont)
    }

    /// 지정된 폰트로 메시지를 표시하는 토스트 뷰를 생성합니다.
    public convenience init(message: String, font: NSFont = ToastView.defaultFont) {
        self.init(message: message, font: font, theme: .system)
    }

    /// 지정된 폰트와 테마로 토스트 뷰를 생성합니다.
    public init(
        message: String,
        font: NSFont = ToastView.defaultFont,
        theme: ToastTheme = .system
    ) {
        self.theme = theme
        super.init(frame: .zero)
        label.stringValue = message
        label.font = font
        setup()
        applyTheme()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        wantsLayer = true
        layer?.cornerRadius = ToastLayout.cornerRadius
        layer?.masksToBounds = true
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(blurView)
        blurView.addSubview(label)

        let textSurface = blurView
        let labelTrailingConstraint = label.trailingAnchor.constraint(
            equalTo: textSurface.trailingAnchor,
            constant: -ToastLayout.textHorizontalInset
        )
        let preferredLabelTop = label.topAnchor.constraint(
            equalTo: textSurface.topAnchor,
            constant: ToastLayout.textVerticalInset
        )
        // 최소 높이로 카드가 확장되면 라벨 자체의 높이를 유지한다.
        preferredLabelTop.priority = .fittingSizeCompression
        self.labelTrailingConstraint = labelTrailingConstraint
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),

            heightAnchor.constraint(greaterThanOrEqualToConstant: ToastLayout.minimumHeight),
            label.centerYAnchor.constraint(equalTo: textSurface.centerYAnchor),
            label.topAnchor.constraint(greaterThanOrEqualTo: textSurface.topAnchor, constant: ToastLayout.textVerticalInset),
            preferredLabelTop,
            label.leadingAnchor.constraint(equalTo: textSurface.leadingAnchor, constant: ToastLayout.textHorizontalInset),
            labelTrailingConstraint,
        ])
    }

    public override func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
        if superview == nil {
            presenter = nil
        }
    }

    public override func viewDidChangeEffectiveAppearance() {
        super.viewDidChangeEffectiveAppearance()
        if theme == .system {
            applyTheme()
        }
    }

    private func applyTheme() {
        let systemIsDark = effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        let usesLightAppearance = theme.usesLightAppearance(systemIsDark: systemIsDark)
        blurView.appearance = NSAppearance(named: usesLightAppearance ? .aqua : .darkAqua)
        blurView.material = usesLightAppearance ? .popover : .hudWindow
        label.textColor = usesLightAppearance ? .black : .white
        closeButton?.contentTintColor = label.textColor
    }

    fileprivate func enableManualDismiss(_ action: @escaping () -> Void) {
        dismissAction = action
        let button = ToastCloseButton(frame: .zero)
        let configuration = NSImage.SymbolConfiguration(pointSize: ToastLayout.closeIconSize, weight: .semibold)
        button.image = NSImage(systemSymbolName: "xmark", accessibilityDescription: nil)?
            .withSymbolConfiguration(configuration)
        button.imagePosition = .imageOnly
        button.isBordered = false
        button.setAccessibilityLabel("토스트 닫기")
        button.contentTintColor = label.textColor
        button.target = self
        button.action = #selector(dismissManually)
        closeButton = button
        button.translatesAutoresizingMaskIntoConstraints = false
        let textSurface = blurView
        textSurface.addSubview(button)

        let font = label.font ?? Self.defaultFont
        let firstLineCenterOffset = -(font.ascender + font.descender) / 2
        labelTrailingConstraint?.isActive = false
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: ToastLayout.closeTargetSize),
            button.heightAnchor.constraint(equalTo: button.widthAnchor),
            button.centerYAnchor.constraint(equalTo: label.firstBaselineAnchor, constant: firstLineCenterOffset),
            button.topAnchor.constraint(greaterThanOrEqualTo: textSurface.topAnchor),
            button.bottomAnchor.constraint(lessThanOrEqualTo: textSurface.bottomAnchor),
            button.trailingAnchor.constraint(equalTo: textSurface.trailingAnchor, constant: -ToastLayout.closeTrailingInset),
            label.trailingAnchor.constraint(equalTo: button.leadingAnchor, constant: -ToastLayout.closeLabelSpacing),
        ])
    }

    @objc private func dismissManually() {
        let action = dismissAction
        dismissAction = nil
        action?()
    }

    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.45
        animation.values = [0, -10, 10, -8, 8, -5, 5, 0]
        layer?.add(animation, forKey: "shake")
    }
}

// MARK: - Toast Presenter

fileprivate final class MacToastPresenter {

    private weak var toast: ToastView?
    private let duration: TimeInterval?
    private let type: ToastType
    private let isShowTop: Bool
    private var topConstraint: NSLayoutConstraint?
    private var dismissTimer: Timer?
    private var isDismissing = false

    init(toast: ToastView, duration: TimeInterval?, type: ToastType, isShowTop: Bool) {
        self.toast = toast
        self.duration = duration
        self.type = type
        self.isShowTop = isShowTop
    }

    deinit {
        dismissTimer?.invalidate()
    }

    func present(in containerView: NSView) {
        guard let toast else { return }
        containerView.addSubview(toast)
        if duration == nil {
            toast.enableManualDismiss { [weak self] in self?.dismiss() }
        }

        var constraints = [
            toast.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            toast.widthAnchor.constraint(
                lessThanOrEqualTo: containerView.widthAnchor,
                constant: -2 * ToastLayout.windowHorizontalInset
            ),
        ]

        if isShowTop {
            let topConstraint = toast.topAnchor.constraint(equalTo: containerView.topAnchor, constant: -100)
            self.topConstraint = topConstraint
            constraints.append(topConstraint)
        } else {
            constraints.append(toast.centerYAnchor.constraint(equalTo: containerView.centerYAnchor))
        }

        NSLayoutConstraint.activate(constraints)
        containerView.layoutSubtreeIfNeeded()
        toast.alphaValue = 0

        if isShowTop {
            topConstraint?.constant = 16
        }

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            context.allowsImplicitAnimation = true
            toast.animator().alphaValue = 1
            containerView.layoutSubtreeIfNeeded()
        } completionHandler: { [weak self] in
            guard let self, !self.isDismissing, let toast = self.toast, toast.superview != nil else { return }
            if self.type == .negative {
                toast.shake()
            }
            if let duration = self.duration {
                self.dismissTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
                    self?.dismiss()
                }
            }
        }
    }

    private func dismiss() {
        guard !isDismissing, let toast, let containerView = toast.superview else { return }
        isDismissing = true
        if isShowTop {
            topConstraint?.constant = -(toast.bounds.height + 32)
        }

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            context.allowsImplicitAnimation = true
            toast.animator().alphaValue = 0
            containerView.layoutSubtreeIfNeeded()
        } completionHandler: {
            toast.removeFromSuperview()
        }
    }
}

private func presentToast(
    message: String,
    duration: ToastDuration,
    isShowTop: Bool,
    type: ToastType,
    font: NSFont,
    theme: ToastTheme
) {
    DispatchQueue.main.async {
        guard let window = NSApp.keyWindow ?? NSApp.windows.first(where: { $0.isVisible }),
              let containerView = window.contentView else { return }

        let toast = ToastView(message: message, font: font, theme: theme)
        let presenter = MacToastPresenter(
            toast: toast,
            duration: duration.seconds,
            type: type,
            isShowTop: isShowTop
        )
        toast.presenter = presenter
        presenter.present(in: containerView)
    }
}

// MARK: - AppKit Extensions

public extension NSView {
    /// 현재 윈도우에 기본 폰트로 토스트를 표시합니다.
    func sbShowToast(
        message: String,
        duration: ToastDuration = .short,
        isShowTop: Bool = false,
        type: ToastType = .positive
    ) {
        sbShowToast(message: message, duration: duration, isShowTop: isShowTop, type: type, font: ToastView.defaultFont)
    }

    /// 현재 윈도우에 토스트를 표시합니다.
    /// - Parameters:
    ///   - font: 메시지에 사용할 폰트. 기본값은 14pt Medium 시스템 폰트입니다.
    func sbShowToast(
        message: String,
        duration: ToastDuration = .short,
        isShowTop: Bool = false,
        type: ToastType = .positive,
        font: NSFont = ToastView.defaultFont
    ) {
        sbShowToast(message: message, duration: duration, isShowTop: isShowTop, type: type, font: font, theme: .system)
    }

    /// 지정된 테마로 현재 윈도우에 토스트를 표시합니다.
    /// - Parameters:
    ///   - theme: 배경과 글자색을 결정합니다. 기본값은 시스템 설정과 반대 테마를 적용하는 `.system`입니다.
    func sbShowToast(
        message: String,
        duration: ToastDuration = .short,
        isShowTop: Bool = false,
        type: ToastType = .positive,
        font: NSFont = ToastView.defaultFont,
        theme: ToastTheme = .system
    ) {
        presentToast(message: message, duration: duration, isShowTop: isShowTop, type: type, font: font, theme: theme)
    }
}

public extension NSViewController {
    /// 현재 윈도우에 기본 폰트로 토스트를 표시합니다.
    func sbShowToast(
        message: String,
        duration: ToastDuration = .short,
        isShowTop: Bool = false,
        type: ToastType = .positive
    ) {
        sbShowToast(message: message, duration: duration, isShowTop: isShowTop, type: type, font: ToastView.defaultFont)
    }

    /// 현재 윈도우에 토스트를 표시합니다.
    /// - Parameters:
    ///   - font: 메시지에 사용할 폰트. 기본값은 14pt Medium 시스템 폰트입니다.
    func sbShowToast(
        message: String,
        duration: ToastDuration = .short,
        isShowTop: Bool = false,
        type: ToastType = .positive,
        font: NSFont = ToastView.defaultFont
    ) {
        sbShowToast(message: message, duration: duration, isShowTop: isShowTop, type: type, font: font, theme: .system)
    }

    /// 지정된 테마로 현재 윈도우에 토스트를 표시합니다.
    /// - Parameters:
    ///   - theme: 배경과 글자색을 결정합니다. 기본값은 시스템 설정과 반대 테마를 적용하는 `.system`입니다.
    func sbShowToast(
        message: String,
        duration: ToastDuration = .short,
        isShowTop: Bool = false,
        type: ToastType = .positive,
        font: NSFont = ToastView.defaultFont,
        theme: ToastTheme = .system
    ) {
        presentToast(message: message, duration: duration, isShowTop: isShowTop, type: type, font: font, theme: theme)
    }
}

public extension View {
    /// 현재 윈도우에 기본 폰트로 토스트를 표시합니다.
    func sbShowToast(
        message: String,
        duration: ToastDuration = .short,
        isShowTop: Bool = false,
        type: ToastType = .positive
    ) {
        sbShowToast(message: message, duration: duration, isShowTop: isShowTop, type: type, font: ToastView.defaultFont)
    }

    /// 현재 윈도우에 토스트를 표시합니다.
    /// - Parameters:
    ///   - font: 메시지에 사용할 폰트. 기본값은 14pt Medium 시스템 폰트입니다.
    func sbShowToast(
        message: String,
        duration: ToastDuration = .short,
        isShowTop: Bool = false,
        type: ToastType = .positive,
        font: NSFont = ToastView.defaultFont
    ) {
        sbShowToast(message: message, duration: duration, isShowTop: isShowTop, type: type, font: font, theme: .system)
    }

    /// 지정된 테마로 현재 윈도우에 토스트를 표시합니다.
    /// - Parameters:
    ///   - theme: 배경과 글자색을 결정합니다. 기본값은 시스템 설정과 반대 테마를 적용하는 `.system`입니다.
    func sbShowToast(
        message: String,
        duration: ToastDuration = .short,
        isShowTop: Bool = false,
        type: ToastType = .positive,
        font: NSFont = ToastView.defaultFont,
        theme: ToastTheme = .system
    ) {
        presentToast(message: message, duration: duration, isShowTop: isShowTop, type: type, font: font, theme: theme)
    }
}
#endif
