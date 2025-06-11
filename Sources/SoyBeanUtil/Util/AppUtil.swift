//
//  AppUtil.swift
//  SoyBean
//
//  Created by 구태호 on 2/12/25.
//

import SoyBeanCore


#if os(iOS)
import UIKit

public class AppUtil {
    /// 앱 종료
    public static func exitApp() {
        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            exit(0)
        }
    }
    
    /// 설정 > 앱 열기
    public static func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    /// 사파리로 열기
    public static func openSafari(url: String) throws {
        let url = url.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let url = URL(string: url) else {
            throw SoyBeanError.invalidURL
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:])
        } else {
            throw SoyBeanError.externalAppOpenError
        }
    }
    
    /// 앱 스토어 열기
    /// - Parameters:
    ///     - appStoreUrl: 앱 스토어 url
    ///     - completion: 앱 스토어 열린 후 실행할 동작
    public static func openAppStore(appStoreUrl: String, completion: (() -> ())?) {
        if let url = URL(string: appStoreUrl),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
            completion?()
        }
    }
}

public extension AppUtil {
    /// 클립보드 저장
    static var clipboard: String? {
        get { UIPasteboard.general.string?.toOptionalIfEmpty }
        set { UIPasteboard.general.string = newValue }
    }
}
#elseif os(macOS)
import AppKit

public class Util {
    
}

public extension Util {
    /// 클립보드 저장
    static var clipboard: String? {
        get { NSPasteboard.general.string(forType: .string) }
        set {
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString(newValue ?? "", forType: .string)
        }
    }
}
#endif
