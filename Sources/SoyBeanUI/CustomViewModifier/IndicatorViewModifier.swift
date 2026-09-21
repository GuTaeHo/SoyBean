import SwiftUI

/// 로딩 중인 화면을 표시하는 방법입니다.
public enum ViewIndicatorType: Sendable {
    case roundLoading
    case blurOnly
}

public extension View {
    /// 로딩 중에는 내용을 흐리게 하고 사용자 입력을 막습니다.
    func indicator(
        isLoading: Bool,
        backgroundColor: Color = .white,
        tintColor: Color = .primary,
        indicatorType: ViewIndicatorType = .roundLoading
    ) -> some View {
        ZStack {
            self
                .disabled(isLoading)
                .blur(radius: isLoading ? 5 : 0)

            if case .roundLoading = indicatorType {
                ProgressView()
                    .padding()
                    .background(backgroundColor)
                    .accentColor(tintColor)
                    .clipShape(Circle())
                    .shadow(radius: 10)
                    .opacity(isLoading ? 1 : 0)
            }
        }
        .animation(.easeInOut, value: isLoading)
    }
}
