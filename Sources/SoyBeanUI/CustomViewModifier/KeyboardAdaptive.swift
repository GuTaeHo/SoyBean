#if os(iOS)
import Combine
import SwiftUI
import UIKit
import SoyBeanCore

private struct KeyboardAdaptive: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0

    let defaultPadding: CGFloat
    let isIgnoreSafeArea: Bool

    func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboardHeight > 0 ? keyboardHeight : defaultPadding)
            .onReceive(Publishers.keyboardHeightPublisher) { height in
                let safeArea = isIgnoreSafeArea ? Self.bottomSafeArea : 0
                let changedHeight = max(0, height - safeArea)

                withAnimation(.easeOut(duration: 0.25)) {
                    keyboardHeight = changedHeight
                }
            }
    }

    private static var bottomSafeArea: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)?
            .safeAreaInsets.bottom ?? 0
    }
}

public extension View {
    /// 키보드 높이에 맞춰 하단 여백을 변경합니다.
    func keyboardAdaptive(
        _ padding: CGFloat = 0,
        isIgnoreSafeArea: Bool = true
    ) -> some View {
        modifier(
            KeyboardAdaptive(
                defaultPadding: padding,
                isIgnoreSafeArea: isIgnoreSafeArea
            )
        )
    }
}
#endif
