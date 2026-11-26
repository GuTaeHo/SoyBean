//
//  UIApplication+.swift
//  SoyBean
//
//  Created by 구태호 on 11/10/24.
//

#if os(iOS)
import UIKit


@available(iOSApplicationExtension, unavailable)
public extension UIApplication {
    /// 연결된 모든 씬에서 현재 키 윈도우를 찾아 반환합니다.
    var currentWindow: UIWindow? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)
    }

    /// 현재 키 윈도우의 하단 안전 영역 높이. 키 윈도우가 없으면 0 입니다.
    var bottomSafeArea: CGFloat {
        currentWindow?.safeAreaInsets.bottom ?? 0
    }

    /// 현재 키 윈도우에서 화면에 보이는 최상위 뷰 컨트롤러
    var topViewController: UIViewController? {
        UIWindow.topViewController(currentWindow?.rootViewController)
    }
}

public extension UIWindow {
    /// 이 윈도우에서 화면에 보이는 최상위 뷰 컨트롤러
    var visibleViewController: UIViewController? {
        UIWindow.topViewController(rootViewController)
    }

    /// 내비게이션·탭·모달 계층을 따라 내려가 화면에 보이는 최상위 뷰 컨트롤러를 반환합니다.
    /// - Parameter rootViewController: 탐색을 시작할 뷰 컨트롤러
    static func topViewController(_ rootViewController: UIViewController?) -> UIViewController? {
        if let presented = rootViewController?.presentedViewController {
            return topViewController(presented)
        }
        if let navigationController = rootViewController as? UINavigationController {
            return topViewController(navigationController.visibleViewController) ?? navigationController
        }
        if let tabBarController = rootViewController as? UITabBarController,
           let selected = tabBarController.selectedViewController {
            return topViewController(selected)
        }
        return rootViewController
    }
}

#endif
