#if os(iOS)
import Combine
import UIKit

public extension Publishers {
    /// UIControl 이벤트가 발생할 때 값을 전달합니다.
    struct ControlEvent<Control: UIControl>: Publisher {
        public typealias Output = Void
        public typealias Failure = Never

        private let control: Control
        private let event: Control.Event

        public init(control: Control, event: Control.Event) {
            self.control = control
            self.event = event
        }

        public func receive<S: Subscriber>(subscriber: S)
        where S.Input == Output, S.Failure == Failure {
            let subscription = ControlEventSubscription(
                subscriber: subscriber,
                control: control,
                event: event
            )
            subscriber.receive(subscription: subscription)
        }
    }

    /// UIControl 이벤트가 발생할 때 지정한 속성 값을 전달합니다.
    struct ControlProperty<Control: UIControl, Value>: Publisher {
        public typealias Output = Value
        public typealias Failure = Never

        private let control: Control
        private let event: Control.Event
        private let keyPath: KeyPath<Control, Value>

        public init(
            control: Control,
            event: Control.Event,
            keyPath: KeyPath<Control, Value>
        ) {
            self.control = control
            self.event = event
            self.keyPath = keyPath
        }

        public func receive<S: Subscriber>(subscriber: S)
        where S.Input == Output, S.Failure == Failure {
            let subscription = ControlPropertySubscription(
                subscriber: subscriber,
                control: control,
                event: event,
                keyPath: keyPath
            )
            subscriber.receive(subscription: subscription)
        }
    }
}

private final class ControlEventSubscription<SubscriberType: Subscriber, Control: UIControl>: Subscription
where SubscriberType.Input == Void, SubscriberType.Failure == Never {
    private var subscriber: SubscriberType?
    private weak var control: Control?
    private let event: Control.Event
    private let actionIdentifier: UIAction.Identifier

    init(subscriber: SubscriberType, control: Control, event: Control.Event) {
        self.subscriber = subscriber
        self.control = control
        self.event = event

        actionIdentifier = UIAction.Identifier(UUID().uuidString)

        let action = UIAction(identifier: actionIdentifier) { [weak self] _ in
            _ = self?.subscriber?.receive(())
        }
        control.addAction(action, for: event)
    }

    func request(_ demand: Subscribers.Demand) { }

    func cancel() {
        control?.removeAction(identifiedBy: actionIdentifier, for: event)
        subscriber = nil
    }
}

private final class ControlPropertySubscription<SubscriberType: Subscriber, Control: UIControl, Value>: Subscription
where SubscriberType.Input == Value, SubscriberType.Failure == Never {
    private var subscriber: SubscriberType?
    private weak var control: Control?
    private let event: Control.Event
    private let keyPath: KeyPath<Control, Value>
    private let actionIdentifier: UIAction.Identifier
    private var didSendFirstValue = false

    init(
        subscriber: SubscriberType,
        control: Control,
        event: Control.Event,
        keyPath: KeyPath<Control, Value>
    ) {
        self.subscriber = subscriber
        self.control = control
        self.event = event
        self.keyPath = keyPath

        actionIdentifier = UIAction.Identifier(UUID().uuidString)

        let action = UIAction(identifier: actionIdentifier) { [weak self] _ in
            guard let self, let control = self.control else { return }
            _ = self.subscriber?.receive(control[keyPath: self.keyPath])
        }
        control.addAction(action, for: event)
    }

    func request(_ demand: Subscribers.Demand) {
        guard demand > .none,
              !didSendFirstValue,
              let subscriber,
              let control else { return }

        didSendFirstValue = true
        _ = subscriber.receive(control[keyPath: keyPath])
    }

    func cancel() {
        control?.removeAction(identifiedBy: actionIdentifier, for: event)
        subscriber = nil
    }
}

public extension UIControl {
    /// 지정한 컨트롤 이벤트를 Publisher로 반환합니다.
    func controlEventPublisher(for event: UIControl.Event) -> AnyPublisher<Void, Never> {
        Publishers.ControlEvent(control: self, event: event)
            .eraseToAnyPublisher()
    }
}

public extension UIControl.Event {
    /// 값 변경을 확인할 때 사용하는 기본 이벤트 묶음입니다.
    static var defaultValueEvents: UIControl.Event {
        [.allEditingEvents, .valueChanged]
    }
}

public extension UIButton {
    /// 버튼의 touchUpInside 이벤트를 전달합니다.
    var touchUpInsidePublisher: AnyPublisher<Void, Never> {
        controlEventPublisher(for: .touchUpInside)
    }
}

public extension UIRefreshControl {
    /// 새로고침 상태를 현재 값부터 전달합니다.
    var isRefreshingPublisher: AnyPublisher<Bool, Never> {
        Publishers.ControlProperty(
            control: self,
            event: .defaultValueEvents,
            keyPath: \.isRefreshing
        )
        .eraseToAnyPublisher()
    }
}
#endif
