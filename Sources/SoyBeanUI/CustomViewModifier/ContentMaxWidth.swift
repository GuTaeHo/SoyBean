import SwiftUI

#if os(iOS)
private struct ContentMaxWidth: ViewModifier {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    let maxWidth: CGFloat

    func body(content: Content) -> some View {
        if horizontalSizeClass == .regular {
            content
                .frame(maxWidth: maxWidth)
                .frame(maxWidth: .infinity)
        } else {
            content
        }
    }
}

public extension View {
    /// 화면이 regular 너비일 때 콘텐츠의 최대 너비를 제한하고 가운데 정렬합니다.
    func contentMaxWidth(_ maxWidth: CGFloat = 744) -> some View {
        modifier(ContentMaxWidth(maxWidth: maxWidth))
    }
}
#elseif os(macOS)
public extension View {
    /// 콘텐츠의 최대 너비를 제한하고 가운데 정렬합니다.
    func contentMaxWidth(_ maxWidth: CGFloat = 744) -> some View {
        frame(maxWidth: maxWidth)
            .frame(maxWidth: .infinity)
    }
}
#endif
