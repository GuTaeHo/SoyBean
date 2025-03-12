//
//  Bundle+.swift
//  SoyBean
//
//  Created by 구태호 on 3/12/25.
//

import Foundation


public extension Bundle {
    enum AppInstallEnvironment {
        case direct
        case testFlight
        case appStore
        
        public var name: String {
            switch self {
            case .direct:
                return "직접설치"
            case .testFlight:
                return "테스트플라이트"
            case .appStore:
                return "앱스토어"
            }
        }
    }
    
    /// 앱 설치 환경 반환
    /// - Important: `Mac Catalyst` 를 지원하는 앱에서는 동작하지않음
    var appInstallEnvironment: AppInstallEnvironment {
        #if DEBUG
        return .direct
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
