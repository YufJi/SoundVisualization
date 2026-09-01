import Foundation

protocol RenderScheduling: AnyObject {
    var interval: TimeInterval { get }
    func schedule(interval: TimeInterval, handler: @escaping @Sendable () -> Void)
    func stop()
}

final class TimerRenderScheduler: RenderScheduling {
    private(set) var interval: TimeInterval = 0
    private var timer: Timer?

    func schedule(interval: TimeInterval, handler: @escaping () -> Void) {
        guard interval > 0 else { return }
        self.interval = interval
        timer?.invalidate()
        let timer = Timer(timeInterval: interval, repeats: true) { _ in
            handler()
        }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        interval = 0
    }

    deinit {
        stop()
    }
}
