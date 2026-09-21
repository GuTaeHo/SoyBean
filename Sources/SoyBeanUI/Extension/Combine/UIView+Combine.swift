#if os(iOS)
import Combine
import UIKit

public extension UITapGestureRecognizer {
    /// 탭 제스처 이벤트를 전달하는 Publisher입니다.
    struct GesturePublisher<Recognizer: UITapGestureRecognizer>: Publisher {
        public typealias Output = Recognizer
        public typealias Failure = Never

        private let recognizer: Recognizer
        private let view: UIView

        public init(recognizer: Recognizer, view: UIView) {
            self.recognizer = recognizer
            self.view = view
        }

        public func receive<S: Subscriber>(subscriber: S)
        where S.Input == Recognizer, S.Failure == Never {
            let subscription = GestureSubscription(
                subscriber: subscriber,
                recognizer: recognizer,
                view: view
            )
            subscriber.receive(subscription: subscription)
        }
    }
}

private final class GestureSubscription<SubscriberType: Subscriber, Recognizer: UITapGestureRecognizer>: NSObject, Subscription
where SubscriberType.Input == Recognizer, SubscriberType.Failure == Never {
    private var subscriber: SubscriberType?
    private let recognizer: Recognizer
    private weak var view: UIView?

    init(subscriber: SubscriberType, recognizer: Recognizer, view: UIView) {
        self.subscriber = subscriber
        self.recognizer = recognizer
        self.view = view
        super.init()
        recognizer.addTarget(self, action: #selector(receiveTap))
        view.addGestureRecognizer(recognizer)
    }

    func request(_ demand: Subscribers.Demand) { }

    func cancel() {
        recognizer.removeTarget(self, action: #selector(receiveTap))
        view?.removeGestureRecognizer(recognizer)
        subscriber = nil
    }

    @objc private func receiveTap() {
        _ = subscriber?.receive(recognizer)
    }
}

public extension UIView {
    /// 뷰의 탭 이벤트를 전달합니다.
    var tapPublisher: UITapGestureRecognizer.GesturePublisher<UITapGestureRecognizer> {
        UITapGestureRecognizer.GesturePublisher(
            recognizer: UITapGestureRecognizer(),
            view: self
        )
    }
}
#endif
