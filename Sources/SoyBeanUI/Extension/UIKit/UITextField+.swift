//
//  UITextField+.swift
//  SoyBean
//
//  Created by 구태호 on 3/12/26.
//

import UIKit

public extension UITextField {
    /// 키보드 상단에 버튼이 포함된 툴바를 표시합니다
    func addDoneButtonOnKeyboard(title: String = "닫기",
                                 clickClosure: ((UIBarButtonItem) -> Void)? = nil)
    {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        toolbar.barStyle = .default

        let flexibleSpace = UIBarButtonItem.flexibleSpace()

        var done: UIBarButtonItem

        if #available(iOS 26, *) {
            done = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(doneButtonAction))
            if let clickClosure = clickClosure {
                done = UIBarButtonItem(title: title, style: .plain, closure: clickClosure)
            }
        } else {
            done = UIBarButtonItem(title: title, style: .done, target: self, action: #selector(doneButtonAction))
            if let clickClosure = clickClosure {
                done = UIBarButtonItem(title: title, style: .done, closure: clickClosure)
            }
            done.tintColor = .darkGray
        }

        let toolbarItems = [flexibleSpace, done]
        toolbar.setItems(toolbarItems, animated: true)
        toolbar.sizeToFit()

        inputAccessoryView = toolbar
    }

    /// 키보드 상단에 이전/다음/완료 버튼이 포함된 툴바를 표시합니다
    func addPreviousNextDoneOnKeyboard(previousTitle: String = "이전",
                                               nextTitle: String = "다음",
                                               doneTitle: String = "완료",
                                               isPreviousEnabled: Bool = true,
                                               isNextEnabled: Bool = true,
                                               previousClosure: @escaping (UIBarButtonItem) -> Void = { _ in },
                                               nextClosure: @escaping (UIBarButtonItem) -> Void = { _ in },
                                               doneClosure: ((UIBarButtonItem) -> Void)? = nil)
    {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        toolbar.barStyle = .default

        let previous = UIBarButtonItem(title: previousTitle, style: .plain, closure: previousClosure)
        previous.isEnabled = isPreviousEnabled

        let next = UIBarButtonItem(title: nextTitle, style: .plain, closure: nextClosure)
        next.isEnabled = isNextEnabled

        let flexibleSpace = UIBarButtonItem.flexibleSpace()

        let done: UIBarButtonItem
        if let doneClosure = doneClosure {
            done = UIBarButtonItem(title: doneTitle, style: .plain, closure: doneClosure)
        } else {
            done = UIBarButtonItem(title: doneTitle, style: .done, target: self, action: #selector(doneButtonAction))
        }

        if #available(iOS 26, *) {
            // 기본 스타일 유지
        } else {
            previous.tintColor = .darkGray
            next.tintColor = .darkGray
            done.tintColor = .darkGray
        }

        let toolbarItems = [previous, next, flexibleSpace, done]
        toolbar.setItems(toolbarItems, animated: true)
        toolbar.sizeToFit()

        inputAccessoryView = toolbar
    }

    @objc public func doneButtonAction() {
        resignFirstResponder()
    }
}
