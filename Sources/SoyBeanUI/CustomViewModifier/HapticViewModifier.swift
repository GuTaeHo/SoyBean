#if os(iOS)
import SwiftUI

private struct AlertPresentationHapticModifier: ViewModifier {
    let isPresented: Bool

    func body(content: Content) -> some View {
        content.onChange(of: isPresented) { isPresented in
            guard isPresented else { return }
            HapticManager.shared.start(.notification(.warning))
        }
    }
}

private struct ControlValueHapticModifier<Value: Equatable>: ViewModifier {
    let value: Value

    func body(content: Content) -> some View {
        content.onChange(of: value) { _ in
            HapticManager.shared.start(.selection)
        }
    }
}

public extension View {
    /// 얼럿이 표시될 때 경고 햅틱을 실행합니다.
    func alertPresentationHaptics(isPresented: Bool) -> some View {
        modifier(AlertPresentationHapticModifier(isPresented: isPresented))
    }

    /// 값이 변경될 때 선택 햅틱을 실행합니다.
    func controlValueHaptics<Value: Equatable>(value: Value) -> some View {
        modifier(ControlValueHapticModifier(value: value))
    }
}
#endif
