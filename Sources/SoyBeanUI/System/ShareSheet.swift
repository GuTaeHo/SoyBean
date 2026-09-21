#if os(iOS)
import SwiftUI
import UIKit

/// UIKit 공유 화면을 SwiftUI에서 표시합니다.
public struct ShareSheet: UIViewControllerRepresentable {
    public let items: [Any]
    public let activities: [UIActivity]?

    public init(items: [Any], activities: [UIActivity]? = nil) {
        self.items = items
        self.activities = activities
    }

    public func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(
            activityItems: items,
            applicationActivities: activities
        )
    }

    public func updateUIViewController(
        _ uiViewController: UIActivityViewController,
        context: Context
    ) { }
}

public extension View {
    /// 문자열, URL 또는 이미지 등을 전달하는 공유 화면을 표시합니다.
    func shareSheet(
        isPresented: Binding<Bool>,
        items: [Any],
        activities: [UIActivity]? = nil
    ) -> some View {
        sheet(isPresented: isPresented) {
            ShareSheet(items: items, activities: activities)
        }
    }
}
#endif
