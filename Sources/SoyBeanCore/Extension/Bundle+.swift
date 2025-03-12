//
//  Bundle+.swift
//  SoyBean
//
//  Created by 구태호 on 3/12/25.
//

import Foundation


public extension Bundle {
    enum AppConfiguration {
        case debug
        case testFlight
        case appStore
    }
    
    /// 앱 설치 환경 반환
    /// - Important: `Mac Catalyst` 를 지원하는 앱에서는 동작하지않음
    var appInstallEnvironment: AppConfiguration {
        #if DEBUG
        return .debug
        #else
        if Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt" {
            return .testFlight
        } else {
            return .appStore
        }
        #endif
    }
    
    var appBundleID: String { Bundle.main.bundleIdentifier ?? "" }
    
    var appName: String { Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "" }
    
    var appVersion: String { Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "" }
    
    var appBuildNumber: String { Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "" }
}
