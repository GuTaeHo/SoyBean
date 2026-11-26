//
//  UICollectionView+.swift
//  SoyBean
//
//  Created by 구태호 on 2023/05/22.
//

#if os(iOS)
import UIKit
import SoyBeanCore


/// 클래스 이름을 재사용 식별자로 사용해 셀과 보충 뷰를 등록하고 꺼냅니다.
public extension UICollectionView {
    /// 보충 뷰 종류 (`UICollectionView.elementKindSectionHeader` 등)
    typealias SupplementaryViewKind = String

    /// 클래스로 셀을 등록합니다.
    func registerCell<T: UICollectionViewCell>(_ classType: T.Type) {
        register(classType, forCellWithReuseIdentifier: classType.className)
    }

    /// nib 으로 셀을 등록합니다. nib 파일 이름은 클래스 이름과 같아야 합니다.
    /// - Parameters:
    ///   - classType: 셀 타입
    ///   - bundle: nib 이 들어 있는 번들. `nil` 이면 메인 번들
    func registerCellFromNib<T: UICollectionViewCell>(_ classType: T.Type, bundle: Bundle? = nil) {
        register(UINib(nibName: classType.className, bundle: bundle), forCellWithReuseIdentifier: classType.className)
    }

    /// 클래스로 보충 뷰를 등록합니다.
    /// - Parameters:
    ///   - classType: 보충 뷰 타입
    ///   - elementKind: 보충 뷰 종류 (헤더, 푸터 등)
    func registerSupplementaryView<T: UICollectionReusableView>(_ classType: T.Type, ofKind elementKind: SupplementaryViewKind) {
        register(classType, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: classType.className)
    }

    /// nib 으로 보충 뷰를 등록합니다. nib 파일 이름은 클래스 이름과 같아야 합니다.
    /// - Parameters:
    ///   - classType: 보충 뷰 타입
    ///   - elementKind: 보충 뷰 종류 (헤더, 푸터 등)
    ///   - bundle: nib 이 들어 있는 번들. `nil` 이면 메인 번들
    func registerSupplementaryViewFromNib<T: UICollectionReusableView>(
        _ classType: T.Type,
        ofKind elementKind: SupplementaryViewKind,
        bundle: Bundle? = nil
    ) {
        register(
            UINib(nibName: classType.className, bundle: bundle),
            forSupplementaryViewOfKind: elementKind,
            withReuseIdentifier: classType.className
        )
    }

    /// 등록한 타입으로 캐스팅된 재사용 셀을 꺼냅니다.
    /// - Note: 등록하지 않았거나 타입이 다르면 디버그 빌드에서 중단하고, 릴리스 빌드에서는 빈 셀을 반환합니다.
    func dequeueCell<T: UICollectionViewCell>(_ classType: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: classType.className, for: indexPath) as? T else {
            assertionFailure("\(classType.className) 셀을 꺼낼 수 없습니다. 등록 여부와 타입을 확인하세요.")
            return T()
        }
        return cell
    }

    /// 등록한 타입으로 캐스팅된 재사용 보충 뷰를 꺼냅니다.
    /// - Note: 등록하지 않았거나 타입이 다르면 디버그 빌드에서 중단하고, 릴리스 빌드에서는 빈 뷰를 반환합니다.
    func dequeueSupplementaryView<T: UICollectionReusableView>(
        _ classType: T.Type,
        ofKind elementKind: SupplementaryViewKind,
        for indexPath: IndexPath
    ) -> T {
        guard let view = dequeueReusableSupplementaryView(
            ofKind: elementKind,
            withReuseIdentifier: classType.className,
            for: indexPath
        ) as? T else {
            assertionFailure("\(classType.className) 보충 뷰를 꺼낼 수 없습니다. 등록 여부와 타입을 확인하세요.")
            return T()
        }
        return view
    }
}

public extension UICollectionView {
    /// 해당 위치의 아이템으로 스크롤합니다.
    /// - Parameters:
    ///   - indexPath: 아이템 위치
    ///   - alignment: 스크롤 후 아이템 정렬 위치
    ///   - animated: 애니메이션 여부
    func scroll(
        to indexPath: IndexPath,
        alignment: UICollectionView.ScrollPosition = .centeredHorizontally,
        animated: Bool = true
    ) {
        scrollToItem(at: indexPath, at: alignment, animated: animated)
    }

    /// `contentInset` 을 포함한 최상단으로 스크롤합니다.
    func scrollToTopWithContentInsets(animated: Bool = true) {
        setContentOffset(CGPoint(x: -adjustedContentInset.left, y: -adjustedContentInset.top), animated: animated)
    }
}

#endif
