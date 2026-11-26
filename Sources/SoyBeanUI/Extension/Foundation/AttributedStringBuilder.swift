//
//  AttributedStringBuilder.swift
//  SoyBean
//
//  Created by 구태호 on 9/2/24.
//

#if os(iOS) || os(macOS)
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif


/// 속성이 다른 문자열 조각을 체이닝으로 이어 붙여 `NSAttributedString` 또는 `AttributedString` 을 만듭니다.
///
/// ```swift
/// let text: NSAttributedString? = AttributedStringBuilder
///     .factory(default: [.font(.systemFont(ofSize: 14))])
///     .text("가격 ")
///     .text("1,100원", attributes: [.foregroundColor(.systemRed)])
///     .build()
/// ```
public final class AttributedStringBuilder {
#if os(iOS)
    /// 플랫폼 폰트 타입
    public typealias PlatformFont = UIFont
    /// 플랫폼 색상 타입
    public typealias PlatformColor = UIColor
#elseif os(macOS)
    /// 플랫폼 폰트 타입
    public typealias PlatformFont = NSFont
    /// 플랫폼 색상 타입
    public typealias PlatformColor = NSColor
#endif

    fileprivate typealias AttributeContainer = [NSAttributedString.Key: Any]
    fileprivate typealias AttributeItem = (key: NSAttributedString.Key, value: Any?)

    /// 문자열 조각에 적용할 속성
    public enum Attribute {
        /// 폰트
        case font(PlatformFont)
        /// SoyBean 번들 폰트. 등록되지 않았으면 같은 크기의 시스템 폰트를 사용합니다.
        case customFont(FontType, size: CGFloat)
        /// 텍스트 색상
        case foregroundColor(PlatformColor?)
        /// 배경 색상
        case backgroundColor(PlatformColor?)
        /// 취소선
        case strikethrough(Bool = true, pattern: NSUnderlineStyle = .single, color: PlatformColor? = nil)
        /// 밑줄
        case underline(Bool = true, pattern: NSUnderlineStyle = .single, color: PlatformColor? = nil)
        /// 자간 (kern)
        case kerning(CGFloat)
        /// 자간 (tracking)
        case tracking(CGFloat)
        /// 기준선 오프셋
        case baselineOffset(CGFloat)
        /// 외곽선 (색상, 선 두께)
        case stroke(PlatformColor, lineWidth: CGFloat = 1)

        /// 단락 스타일
        case paragraphStyle(NSParagraphStyle)
        /// 텍스트 정렬
        case textAlignment(NSTextAlignment)
        /// 줄 간격
        case lineSpacing(CGFloat)
        /// 줄 바꿈 모드
        case lineBreakMode(NSLineBreakMode = .byWordWrapping, strategy: NSParagraphStyle.LineBreakStrategy = .standard)

        fileprivate var isParagraphAttribute: Bool {
            switch self {
            case .paragraphStyle, .textAlignment, .lineSpacing, .lineBreakMode:
                return true

            default:
                return false
            }
        }

        fileprivate func makeAttributeItems() -> [AttributeItem] {
            switch self {
            case .font(let value):
                return [(.font, value)]

            case .customFont(let type, let size):
                return [(.font, PlatformFont(name: type.rawValue, size: size) ?? .systemFont(ofSize: size))]

            case .foregroundColor(let color):
                return [(.foregroundColor, color)]

            case .backgroundColor(let color):
                return [(.backgroundColor, color)]

            case .strikethrough(let isActive, let pattern, let color):
                return isActive
                ? [(.strikethroughStyle, pattern.rawValue), (.strikethroughColor, color)]
                : []

            case .underline(let isActive, let pattern, let color):
                return isActive
                ? [(.underlineStyle, pattern.rawValue), (.underlineColor, color)]
                : []

            case .kerning(let value):
                return [(.kern, value)]

            case .tracking(let value):
                return [(.tracking, value)]

            case .baselineOffset(let value):
                return [(.baselineOffset, value)]

            case .stroke(let color, let lineWidth):
                return [(.strokeColor, color), (.strokeWidth, lineWidth)]

            case .paragraphStyle, .textAlignment, .lineSpacing, .lineBreakMode:
                return []
            }
        }

        fileprivate func apply(to paragraphStyle: NSMutableParagraphStyle) {
            switch self {
            case .paragraphStyle(let style):
                paragraphStyle.setParagraphStyle(style)

            case .textAlignment(let alignment):
                paragraphStyle.alignment = alignment

            case .lineSpacing(let value):
                paragraphStyle.lineSpacing = value

            case .lineBreakMode(let mode, let strategy):
                paragraphStyle.lineBreakMode = mode
                paragraphStyle.lineBreakStrategy = strategy

            default:
                break
            }
        }
    }

    private let defaultAttributes: [Attribute]
    private let attributedString = NSMutableAttributedString()

    /// 빌더를 생성합니다.
    /// - Parameter defaultAttributes: 모든 조각에 먼저 적용할 기본 속성. 조각별 속성이 같은 속성을 덮어씁니다.
    public static func factory(default defaultAttributes: [Attribute] = []) -> AttributedStringBuilder {
        AttributedStringBuilder(default: defaultAttributes)
    }

    private init(default defaultAttributes: [Attribute]) {
        self.defaultAttributes = defaultAttributes
    }

    /// 문자열을 추가합니다.
    @discardableResult
    public func text(_ string: String, attributes: [Attribute] = []) -> Self {
        attributedString.append(.init(string: string, attributes: makeAttributeContainer(attributes)))
        return self
    }

    /// `AttributedString` 을 속성 그대로 추가합니다.
    @discardableResult
    public func attributedText(_ attributedString: AttributedString) -> Self {
        attributedText(NSAttributedString(attributedString))
    }

    /// `NSAttributedString` 을 속성 그대로 추가합니다.
    @discardableResult
    public func attributedText(_ attributedString: NSAttributedString) -> Self {
        self.attributedString.append(attributedString)
        return self
    }

    /// 공백을 `count` 개 추가합니다.
    @discardableResult
    public func spaces(_ count: Int, attributes: [Attribute] = []) -> Self {
        text(String(repeating: " ", count: max(0, count)), attributes: attributes)
    }

    /// 공백을 하나 추가합니다.
    @discardableResult
    public func space(attributes: [Attribute] = []) -> Self {
        text(" ", attributes: attributes)
    }

    /// 줄바꿈을 `count` 개 추가합니다.
    @discardableResult
    public func newLines(_ count: Int, attributes: [Attribute] = []) -> Self {
        text(String(repeating: "\n", count: max(0, count)), attributes: attributes)
    }

    /// 줄바꿈을 하나 추가합니다.
    @discardableResult
    public func newLine(attributes: [Attribute] = []) -> Self {
        text("\n", attributes: attributes)
    }

    /// 탭을 `count` 개 추가합니다.
    @discardableResult
    public func tabs(_ count: Int, attributes: [Attribute] = []) -> Self {
        text(String(repeating: "\t", count: max(0, count)), attributes: attributes)
    }

    /// 탭을 하나 추가합니다.
    @discardableResult
    public func tab(attributes: [Attribute] = []) -> Self {
        text("\t", attributes: attributes)
    }

    /// 지금까지 추가한 내용을 `NSAttributedString` 또는 `NSMutableAttributedString` 사본으로 반환합니다.
    public func build<T>() -> T? where T: NSAttributedString {
        attributedString.mutableCopy() as? T
    }

    /// 지금까지 추가한 내용을 `AttributedString` 으로 반환합니다.
    public func build() -> AttributedString? {
        AttributedString(attributedString)
    }

    private func makeAttributeContainer(_ newAttributes: [Attribute]) -> AttributeContainer {
        var container = AttributeContainer()
        let paragraphStyle = NSMutableParagraphStyle()

        (defaultAttributes + newAttributes).forEach { attribute in
            if attribute.isParagraphAttribute {
                attribute.apply(to: paragraphStyle)
            } else {
                attribute.makeAttributeItems().forEach { container[$0.key] = $0.value }
            }
        }
        container[.paragraphStyle] = paragraphStyle
        return container
    }
}

#endif
