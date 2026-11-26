//
//  EventLimiter.swift
//  SoyBean
//
//  Created by 구태호 on 2/5/24.
//

import Foundation


/// 짧은 시간에 몰리는 이벤트를 throttle 또는 debounce 로 제한합니다.
///
/// 제한 상태는 인스턴스마다 따로 유지되므로, 제한할 이벤트마다 하나씩 만들어 보관합니다.
/// ```swift
/// let limiter = EventLimiter()
/// limiter.execute(type: .debounce, duration: 0.3) {
///     await search(keyword)
/// }
/// ```
public actor EventLimiter {
    /// 이벤트 제한 방식
    public enum LimitType: Sendable {
        /// 첫 이벤트를 즉시 실행하고, `duration` 동안 들어오는 이벤트는 버립니다.
        case throttle
        /// 마지막 이벤트 후 `duration` 동안 새 이벤트가 없을 때 마지막 이벤트만 실행합니다.
        case debounce
    }

    private var task: Task<Void, Never>?

    public init() {}

    /// 제한 방식에 따라 작업을 실행합니다.
    /// - Parameters:
    ///   - type: 제한 방식
    ///   - duration: 제한 시간 (초)
    ///   - block: 실행할 작업
    public nonisolated func execute(type: LimitType, duration: TimeInterval, _ block: @escaping () async -> Void) {
        Task {
            switch type {
            case .throttle:
                await throttle(duration: duration, block: block)

            case .debounce:
                await debounce(duration: duration, block: block)
            }
        }
    }

    /// 진행 중인 제한 대기를 취소합니다. debounce 로 예약된 작업은 실행되지 않습니다.
    public func cancel() {
        task?.cancel()
        task = nil
    }

    private func throttle(duration: TimeInterval, block: @escaping () async -> Void) {
        guard task == nil else { return }

        Task { await block() }

        task = Task {
            try? await sleep(duration: duration)
            self.task = nil
        }
    }

    private func debounce(duration: TimeInterval, block: @escaping () async -> Void) {
        task?.cancel()

        task = Task {
            do {
                try await sleep(duration: duration)
            } catch {
                return
            }
            guard !Task.isCancelled else { return }
            self.task = nil
            await block()
        }
    }

    private func sleep(duration: TimeInterval) async throws {
        try await Task.sleep(nanoseconds: UInt64(max(0, duration) * 1_000_000_000))
    }
}
