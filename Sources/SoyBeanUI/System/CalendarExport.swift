#if os(iOS)
import EventKit
import EventKitUI
import SwiftUI

/// Apple 캘린더 편집 화면에 전달할 일정입니다.
public struct CalendarExportEvent: Identifiable, Sendable {
    public let id: UUID
    public let title: String
    public let notes: String?
    public let location: String?
    public let startDate: Date
    public let endDate: Date
    public let isAllDay: Bool

    public init(
        id: UUID = UUID(),
        title: String,
        notes: String? = nil,
        location: String? = nil,
        startDate: Date,
        endDate: Date,
        isAllDay: Bool = false
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.location = location
        self.startDate = startDate
        self.endDate = endDate
        self.isAllDay = isAllDay
    }
}

/// 캘린더 내보내기 실패 원인입니다.
public enum CalendarExportError: Identifiable, LocalizedError {
    case accessDenied
    case unavailable

    public var id: Int {
        switch self {
        case .accessDenied: return 0
        case .unavailable: return 1
        }
    }

    public var errorDescription: String? {
        switch self {
        case .accessDenied:
            return "설정 앱에서 캘린더 접근을 허용해 주세요."
        case .unavailable:
            return "캘린더를 열 수 없습니다. 잠시 후 다시 시도해 주세요."
        }
    }
}

/// iOS 버전과 권한 상태를 확인한 뒤 Apple 캘린더 편집 화면을 준비합니다.
@MainActor
public final class CalendarExportManager: ObservableObject {
    @Published fileprivate var pendingEvent: CalendarExportEvent?
    @Published fileprivate var exportError: CalendarExportError?

    fileprivate let eventStore: EKEventStore
    private var isRequestingAccess = false

    public init(eventStore: EKEventStore = EKEventStore()) {
        self.eventStore = eventStore
    }

    /// 전달한 일정을 Apple 캘린더 편집 화면으로 내보냅니다.
    public func export(_ event: CalendarExportEvent) {
        if #available(iOS 17.0, *) {
            pendingEvent = event
            return
        }

        switch EKEventStore.authorizationStatus(for: .event) {
        case .authorized:
            pendingEvent = event
        case .fullAccess, .writeOnly:
            pendingEvent = event
        case .notDetermined:
            requestAccess(for: event)
        case .denied, .restricted:
            exportError = .accessDenied
        @unknown default:
            exportError = .unavailable
        }
    }

    fileprivate func finish() {
        pendingEvent = nil
    }

    private func requestAccess(for event: CalendarExportEvent) {
        guard !isRequestingAccess else { return }
        isRequestingAccess = true

        eventStore.requestAccess(to: .event) { [weak self] isGranted, error in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isRequestingAccess = false

                if isGranted {
                    self.pendingEvent = event
                } else if error == nil {
                    self.exportError = .accessDenied
                } else {
                    self.exportError = .unavailable
                }
            }
        }
    }
}

private struct CalendarEventEditor: UIViewControllerRepresentable {
    let event: CalendarExportEvent
    let eventStore: EKEventStore
    let completion: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(completion: completion)
    }

    func makeUIViewController(context: Context) -> EKEventEditViewController {
        let calendarEvent = EKEvent(eventStore: eventStore)
        calendarEvent.title = event.title
        calendarEvent.notes = event.notes
        calendarEvent.location = event.location
        calendarEvent.isAllDay = event.isAllDay

        if event.isAllDay {
            let calendar = Calendar.current
            let startDate = calendar.startOfDay(for: min(event.startDate, event.endDate))
            let lastDate = calendar.startOfDay(for: max(event.startDate, event.endDate))
            calendarEvent.startDate = startDate
            calendarEvent.endDate = calendar.date(byAdding: .day, value: 1, to: lastDate)
                ?? lastDate.addingTimeInterval(24 * 60 * 60)
        } else {
            calendarEvent.startDate = event.startDate
            calendarEvent.endDate = event.endDate > event.startDate
                ? event.endDate
                : event.startDate.addingTimeInterval(60 * 60)
        }

        let controller = EKEventEditViewController()
        controller.eventStore = eventStore
        controller.event = calendarEvent
        controller.editViewDelegate = context.coordinator
        return controller
    }

    func updateUIViewController(
        _ uiViewController: EKEventEditViewController,
        context: Context
    ) { }

    final class Coordinator: NSObject, EKEventEditViewDelegate {
        private let completion: () -> Void

        init(completion: @escaping () -> Void) {
            self.completion = completion
        }

        func eventEditViewController(
            _ controller: EKEventEditViewController,
            didCompleteWith action: EKEventEditViewAction
        ) {
            completion()
        }
    }
}

private struct CalendarExportModifier: ViewModifier {
    @ObservedObject var manager: CalendarExportManager

    func body(content: Content) -> some View {
        content
            .sheet(item: $manager.pendingEvent) { event in
                CalendarEventEditor(
                    event: event,
                    eventStore: manager.eventStore,
                    completion: manager.finish
                )
            }
            .alert(item: $manager.exportError) { error in
                Alert(
                    title: Text("캘린더에 추가할 수 없어요"),
                    message: Text(error.localizedDescription),
                    dismissButton: .default(Text("확인"))
                )
            }
    }
}

public extension View {
    /// CalendarExportManager가 준비한 캘린더 편집 화면과 오류 안내를 표시합니다.
    func calendarExport(using manager: CalendarExportManager) -> some View {
        modifier(CalendarExportModifier(manager: manager))
    }
}
#endif
