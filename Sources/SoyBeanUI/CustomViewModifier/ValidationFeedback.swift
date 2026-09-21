import SwiftUI

/// 폼 검증 실패 시 흔들림과 스크롤 대상을 관리합니다.
public struct ValidationFeedback<Field: Hashable> {
    private var shakeTriggers: [Field: Int] = [:]

    /// 화면에 보이도록 이동해야 하는 입력 항목입니다.
    public var scrollTarget: Field?

    public init() { }

    /// 입력 항목의 현재 흔들림 값을 반환합니다.
    public func shakeTrigger(for field: Field) -> Int {
        shakeTriggers[field, default: 0]
    }

    /// 검증에 실패한 입력 항목을 표시합니다.
    public mutating func markFailure(_ field: Field) {
        shakeTriggers[field, default: 0] += 1
        scrollTarget = field
    }
}

public extension Animation {
    /// 입력 검증 실패에 사용하는 흔들림 애니메이션입니다.
    static var validationShake: Animation {
        .linear(duration: 0.21)
    }
}

public extension View {
    /// 입력 항목에 검증용 식별자를 지정합니다.
    func validationFieldID<Field: Hashable>(_ field: Field) -> some View {
        id(field)
    }

    /// 검증 실패 항목이 정해지면 해당 위치로 스크롤합니다.
    func scrollsToValidationField<Field: Hashable>(
        _ target: Binding<Field?>,
        proxy: ScrollViewProxy
    ) -> some View {
        onChange(of: target.wrappedValue) { field in
            guard let field else { return }
            withAnimation(.easeInOut(duration: 0.3)) {
                proxy.scrollTo(field, anchor: .center)
            }
            target.wrappedValue = nil
        }
    }
}
