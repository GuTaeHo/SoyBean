//
//  UITableView+.swift
//  SoyBean
//
//  Created by 구태호 on 2023/01/06.
//

#if os(iOS)
import UIKit
import SoyBeanCore


/// 클래스 이름을 재사용 식별자로 사용해 셀과 헤더·푸터 뷰를 등록하고 꺼냅니다.
public extension UITableView {
    /// nib 으로 셀을 등록합니다. nib 파일 이름은 클래스 이름과 같아야 합니다.
    /// - Parameters:
    ///   - nibType: 셀 타입
    ///   - bundle: nib 이 들어 있는 번들. `nil` 이면 메인 번들
    func registerCell<T: UITableViewCell>(fromNib nibType: T.Type, bundle: Bundle? = nil) {
        register(UINib(nibName: nibType.className, bundle: bundle), forCellReuseIdentifier: nibType.className)
    }

    /// nib 으로 헤더·푸터 뷰를 등록합니다. nib 파일 이름은 클래스 이름과 같아야 합니다.
    /// - Parameters:
    ///   - nibType: 헤더·푸터 뷰 타입
    ///   - bundle: nib 이 들어 있는 번들. `nil` 이면 메인 번들
    func registerHeaderFooterNib<T: UITableViewHeaderFooterView>(fromNib nibType: T.Type, bundle: Bundle? = nil) {
        register(UINib(nibName: nibType.className, bundle: bundle), forHeaderFooterViewReuseIdentifier: nibType.className)
    }

    /// 클래스로 셀을 등록합니다.
    func registerCell<T: UITableViewCell>(fromClass classType: T.Type) {
        register(classType, forCellReuseIdentifier: classType.className)
    }

    /// 클래스로 헤더·푸터 뷰를 등록합니다.
    func registerHeaderFooterView<T: UITableViewHeaderFooterView>(fromClass classType: T.Type) {
        register(classType, forHeaderFooterViewReuseIdentifier: classType.className)
    }

    /// 등록한 타입으로 캐스팅된 재사용 셀을 꺼냅니다.
    /// - Note: 등록하지 않았거나 타입이 다르면 디버그 빌드에서 중단하고, 릴리스 빌드에서는 빈 셀을 반환합니다.
    func dequeueCell<T: UITableViewCell>(_ type: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: type.className, for: indexPath) as? T else {
            assertionFailure("\(type.className) 셀을 꺼낼 수 없습니다. 등록 여부와 타입을 확인하세요.")
            return T()
        }
        return cell
    }

    /// 등록한 타입으로 캐스팅된 재사용 헤더·푸터 뷰를 꺼냅니다.
    /// - Note: 등록하지 않았거나 타입이 다르면 디버그 빌드에서 중단하고, 릴리스 빌드에서는 빈 뷰를 반환합니다.
    func dequeueHeaderFooterView<T: UITableViewHeaderFooterView>(from classType: T.Type) -> T {
        guard let view = dequeueReusableHeaderFooterView(withIdentifier: classType.className) as? T else {
            assertionFailure("\(classType.className) 헤더·푸터 뷰를 꺼낼 수 없습니다. 등록 여부와 타입을 확인하세요.")
            return T()
        }
        return view
    }
}

#endif
