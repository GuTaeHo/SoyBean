#if os(iOS)
import UIKit

/// 명시적으로 선택할 수 있는 iOS 토스트의 등장과 퇴장 효과입니다.
public enum ToastMotion {
    /// 안전 영역 상단으로 물방울처럼 내려오고 등장 동작을 역재생하며 퇴장합니다.
    case dropFromTop
    /// 화면 중앙에서 탄성 있게 펼쳐지고 본문을 흐리며 같은 중심으로 접힙니다.
    case foldAtCenter
}

@MainActor
extension ToastMotion {
    private enum Curve {
        case fall, easeOut, settle, linear

        func timingFunction(reversed: Bool) -> CAMediaTimingFunction {
            let y: (Float, Float)
            switch self {
            case .fall: y = (0, 1.0 / 3)
            case .easeOut: y = (1, 1)
            case .settle: y = (0, 1)
            case .linear: y = (1.0 / 3, 2.0 / 3)
            }
            return CAMediaTimingFunction(controlPoints: 1.0 / 3, reversed ? 1 - y.1 : y.0,
                                         2.0 / 3, reversed ? 1 - y.0 : y.1)
        }
    }

    private var duration: TimeInterval { self == .dropFromTop ? 0.47 : 0.34 }

    func play(on toast: ToastView, exiting: Bool, completion: @escaping @MainActor () -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        if exiting { toast.alpha = 0 }
        switch self {
        case .dropFromTop:
            playDrop(on: toast, reversed: exiting)
        case .foldAtCenter:
            playFold(on: toast, exiting: exiting)
        }
        CATransaction.commit()
    }

    private func playDrop(on toast: ToastView, reversed: Bool) {
        let path = [
            pose(y: -82, width: 0.12, height: 0.44),
            pose(y: -9, width: 0.22, height: 1.34),
            pose(y: 8, width: 0.94, height: 0.69),
            pose(width: 1.08, height: 0.95),
            pose(width: 1, height: 1),
        ]
        toast.layer.add(track("transform", path, times: [0, 0.45, 0.65, 0.82, 1],
                              curves: [.fall, .easeOut, .settle, .settle], reversed: reversed), forKey: "toast.drop")
        toast.layer.add(track("opacity", [0, 1, 1], times: [0, 0.22, 1],
                              curves: [.easeOut, .linear], reversed: reversed), forKey: "toast.fade")
        toast.messageLayer.add(track("opacity", [0, 0, 1], times: [0, 0.57, 1],
                                     curves: [.linear, .settle], reversed: reversed), forKey: "toast.message")
    }

    private func playFold(on toast: ToastView, exiting: Bool) {
        let full = pose(width: 1, height: 1)
        if exiting {
            toast.layer.add(track("transform", [full, pose(width: 0.065, height: 0.24)], times: [0, 1],
                                  curves: [.easeOut]), forKey: "toast.fold")
            toast.layer.add(track("opacity", [1, 0], times: [0, 1], curves: [.easeOut]), forKey: "toast.fade")
            toast.messageLayer.add(track("opacity", [1, 0, 0], times: [0, 0.38, 1],
                                         curves: [.easeOut, .linear]), forKey: "toast.message")
        } else {
            let path = [pose(width: 0.055, height: 0.24), pose(width: 1.045, height: 1.025), full]
            toast.layer.add(track("transform", path, times: [0, 0.52, 1],
                                  curves: [.easeOut, .settle]), forKey: "toast.fold")
            toast.layer.add(track("opacity", [0, 1, 1], times: [0, 0.20, 1],
                                  curves: [.easeOut, .linear]), forKey: "toast.fade")
            toast.messageLayer.add(track("opacity", [0, 0, 1, 1], times: [0, 0.23, 0.65, 1],
                                         curves: [.linear, .settle, .linear]), forKey: "toast.message")
        }
    }

    private func pose(y: CGFloat = 0, width: CGFloat, height: CGFloat) -> NSValue {
        let position = CATransform3DMakeTranslation(0, y, 0)
        return NSValue(caTransform3D: CATransform3DScale(position, width, height, 1))
    }

    private func track(
        _ path: String, _ values: [Any], times: [Double], curves: [Curve], reversed: Bool = false
    ) -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation(keyPath: path)
        animation.values = reversed ? Array(values.reversed()) : values
        let keyTimes = reversed ? times.reversed().map { 1 - $0 } : times
        animation.keyTimes = keyTimes.map { NSNumber(value: $0) }
        let keyCurves = reversed ? Array(curves.reversed()) : curves
        animation.timingFunctions = keyCurves.map { $0.timingFunction(reversed: reversed) }
        animation.duration = duration
        return animation
    }
}
#endif
