//
//  UserDefaultsMigratable.swift
//  SoyBean
//
//  Created by 구태호 on 7/18/25.
//

import Foundation


protocol UserDefaultsMigratable {
    associatedtype KeyType: RawRepresentable & CaseIterable where KeyType.RawValue == String
    
    /// 사용중인 모든 키 반환
    var allKeys: [String] { get }
    
    /// 기본 UserDefaults
    var standard: UserDefaults { get }
    
    /// UserDefaults 데이터 일괄 마이그레이션
    /// - Warning: UserDefaultsMigratable 의 키가 서로 일치하지 않을 경우 해당 키에 대한 데이터는 마이그레이션 되지 않음
    func migrate(to miratableUserDefaults: any UserDefaultsMigratable)
}

extension UserDefaultsMigratable {
    public func migrate(to miratableUserDefaults: any UserDefaultsMigratable) {
        for key in self.allKeys {
            if let value = standard.object(forKey: key) {
                miratableUserDefaults.standard.set(value, forKey: key)
            }
        }
    }
}
