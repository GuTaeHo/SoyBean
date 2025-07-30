//
//  RegExpUtil.swift
//  SoyBean
//
//  Created by 구태호 on 2/12/25.
//

import Foundation


public class RegExpUtil {
    public enum RegCase {
        case email
        case password(range: ClosedRange<Int>)
        case birthday
        
        var predicate: String {
            switch self {
            case .email:
                return "[A-Z0-9a-z._%+-]+@[0-9a-zA-Z.-]+\\.[a-zA-Z]{2,3}"
            case .password(let range):
                return "^(?=.*[A-Za-z])(?=.*[0-9]).{\(range.lowerBound),\(range.upperBound)}"
            case .birthday:
                return "^(\\d{4})(0[1-9]|1[0-2])(0[1-9]|[12]\\d|3[01])$"
            }
        }
    }
    
    public static func evaluate(type case: RegCase, compareWith value: String) -> Bool {
        let pred = NSPredicate(format: "SELF MATCHES %@", `case`.predicate)
        
        if pred.evaluate(with: value) {
            if case .birthday = `case` {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyyMMdd"
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                return dateFormatter.date(from: value) != nil
            }
            
            return true
        } else {
            return false
        }
    }
}
