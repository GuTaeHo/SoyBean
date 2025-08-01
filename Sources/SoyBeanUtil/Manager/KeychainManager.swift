//
//  KeychainManager.swift
//  SoyBean
//
//  Created by 구태호 on 6/11/25.
//

import Foundation
import Security


public final class KeychainManager {
    
    public static let shared = KeychainManager()
    
    private init() { }
    
    /// 키체인 저장
    /// - Parameters:
    ///     - groupAt: 키체인 공유 그룹 ID (타겟의 KeyChain Sharing 기능이 활성화 되어있어야 함)
    /// - Note: 이미 key 가 존재할 경우, 삭제 후 저장 (수정 기능과 등일)
    @discardableResult
    public func save<T: Codable>(_ value: T, forKey key: String, groupAt group: String? = nil) -> Bool {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(value) else {
            return false
        }
        
        delete(forKey: key, groupAt: group)
        
        var query: [String: Any] = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : key,
            kSecValueData as String   : data
        ]
        
        if let group = group?.toOptionalIfEmpty {
            query.updateValue(group, forKey: kSecAttrAccessGroup as String)
        }
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    // 키체인 조회
    /// - Parameters:
    ///     - groupAt: 키체인 공유 그룹 ID (타겟의 KeyChain Sharing 기능이 활성화 되어있어야 함)
    public func load<T: Codable>(_ value: T.Type, forKey key: String, groupAt group: String? = nil) -> T? {
        var query: [String: Any] = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : key,
            kSecReturnData as String  : true,
            kSecMatchLimit as String  : kSecMatchLimitOne
        ]
        
        if let group = group?.toOptionalIfEmpty {
            query.updateValue(group, forKey: kSecAttrAccessGroup as String)
        }
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard
            status == errSecSuccess,
            let data = result as? Data
        else {
            return nil
        }
        
        let decoder = JSONDecoder()
        return try? decoder.decode(T.self, from: data)
    }
    
    /// 키체인 수정
    /// - Parameters:
    ///     - groupAt: 키체인 공유 그룹 ID (타겟의 KeyChain Sharing 기능이 활성화 되어있어야 함)
    @discardableResult
    public func update<T: Codable>(_ value: T, forKey key: String, groupAt group: String? = nil) -> Bool {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(value) else {
            return false
        }
        
        var query: [String: Any] = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : key
        ]
        
        if let group = group?.toOptionalIfEmpty {
            query.updateValue(group, forKey: kSecAttrAccessGroup as String)
        }
        
        let attributesToUpdate: [String: Any] = [
            kSecValueData as String   : data
        ]
        
        let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
        return status == errSecSuccess
    }
    
    /// 키체인 삭제
    /// - Parameters:
    ///     - groupAt: 키체인 공유 그룹 ID (타겟의 KeyChain Sharing 기능이 활성화 되어있어야 함)
    @discardableResult
    public func delete(forKey key: String, groupAt group: String? = nil) -> Bool {
        var query: [String: Any] = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : key
        ]
        
        if let group = group?.toOptionalIfEmpty {
            query.updateValue(group, forKey: kSecAttrAccessGroup as String)
        }
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
    
    /// 일괄조회
    /// - Parameters:
    ///     - groupAt: 키체인 공유 그룹 ID (타겟의 KeyChain Sharing 기능이 활성화 되어있어야 함)
    public func loadAll(groupAt group: String? = nil) -> [String: String] {
        var query: [String: Any] = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecReturnAttributes as String: true,
            kSecReturnData as String  : true,
            kSecMatchLimit as String  : kSecMatchLimitAll
        ]
        
        if let group = group?.toOptionalIfEmpty {
            query.updateValue(group, forKey: kSecAttrAccessGroup as String)
        }
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        var items: [String: String] = [:]
        
        if status == errSecSuccess, let array = result as? [[String: Any]] {
            for item in array {
                if let key = item[kSecAttrAccount as String] as? String,
                   let valueData = item[kSecValueData as String] as? Data,
                   let value = String(data: valueData, encoding: .utf8) {
                    items[key] = value
                }
            }
        }
        
        return items
    }
    
    /// 일괄삭제
    /// - Parameters:
    ///     - groupAt: 키체인 공유 그룹 ID (타겟의 KeyChain Sharing 기능이 활성화 되어있어야 함)
    @discardableResult
    public func deleteAll(groupAt group: String? = nil) -> Bool {
        var isAllSucceeded = true
        
        let itemClasses: [CFString] = [
            kSecClassGenericPassword,
            kSecClassInternetPassword,
            kSecClassCertificate,
            kSecClassKey,
            kSecClassIdentity
        ]

        for itemClass in itemClasses {
            var query: [String: Any] = [kSecClass as String : itemClass]
            
            if let group = group?.toOptionalIfEmpty {
                query.updateValue(group, forKey: kSecAttrAccessGroup as String)
            }
            
            let status = SecItemDelete(query as CFDictionary)

            if status != errSecSuccess, status != errSecItemNotFound {
                isAllSucceeded = false
            }
        }
        
        return isAllSucceeded
    }
}
