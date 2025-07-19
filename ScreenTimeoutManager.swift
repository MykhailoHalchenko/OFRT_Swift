import UIKit
import os.log

class ScreenTimeoutManager {
    static let shared = ScreenTimeoutManager()
    
    private var inactivityTimer: Timer?
    private var backgroundTimer: Timer?
    private(set) var isTracking = false
    private(set) var timeoutDuration: TimeInterval = 300
    
    private init() {
        setupNotifications()
    }
    
    private func setupNotifications() {
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(
            self,
            selector: #selector(resetTimer),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        
        notificationCenter.addObserver(
            self,
            selector: #selector(pauseBackgroundTimer),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        notificationCenter.addObserver(
            self,
            selector: #selector(resetTimer),
            name: UIDevice.proximityStateDidChangeNotification,
            object: nil
        )
    }
    
    func startTracking(duration: TimeInterval? = nil) {
        guard !isTracking else {
            os_log(.info, "ScreenTimeoutManager: Already tracking, ignoring start request")
            return
        }
        
        if let duration = duration {
            timeoutDuration = max(30, min(duration, 1800))
        }
        
        startInactivityTimer()
        startBackgroundTimer()
        
        isTracking = true
        UIApplication.shared.isIdleTimerDisabled = true
        os_log(.info, "ScreenTimeoutManager: Started tracking with duration %.0f seconds", timeoutDuration)
    }
    
    private func startInactivityTimer() {
        inactivityTimer?.invalidate()
        inactivityTimer = Timer.scheduledTimer(
            withTimeInterval: timeoutDuration,
            repeats: false
        ) { [weak self] _ in
            self?.handleInactivity()
        }
    }
    
    private func startBackgroundTimer() {
        backgroundTimer?.invalidate()
        backgroundTimer = Timer.scheduledTimer(
            withTimeInterval: timeoutDuration / 2,
            repeats: true
        ) { [weak self] _ in
            self?.checkBackgroundState()
        }
    }
    
    private func checkBackgroundState() {
        guard isTracking else { return }
        
        switch UIApplication.shared.applicationState {
        case .background, .inactive:
            handleInactivity()
        case .active:
            resetTimer()
        @unknown default:
            os_log(.error, "ScreenTimeoutManager: Unknown application state")
        }
    }
    
    private func handleInactivity() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            UIApplication.shared.isIdleTimerDisabled = false
            NotificationCenter.default.post(name: .screenTimeoutDidOccur, object: nil)
            self.stopTracking()
            os_log(.info, "ScreenTimeoutManager: Timeout occurred")
        }
    }
    
    @objc private func resetTimer() {
        guard isTracking else { return }
        startInactivityTimer()
        os_log(.info, "ScreenTimeoutManager: Timer reset")
    }
    
    @objc private func pauseBackgroundTimer() {
        backgroundTimer?.invalidate()
        os_log(.info, "ScreenTimeoutManager: Background timer paused")
    }
    
    func stopTracking() {
        guard isTracking else { return }
        
        inactivityTimer?.invalidate()
        backgroundTimer?.invalidate()
        isTracking = false
        UIApplication.shared.isIdleTimerDisabled = false
        os_log(.info, "ScreenTimeoutManager: Stopped tracking")
    }
    
    deinit {
        stopTracking()
        NotificationCenter.default.removeObserver(self)
        os_log(.info, "ScreenTimeoutManager: Deinitialized")
    }
}

// Расширение для имени уведомления
extension Notification.Name {
    static let screenTimeoutDidOccur = Notification.Name("ScreenTimeoutDidOccur")
}
