import UIKit
import SwiftUI

protocol ScreenTimeoutDelegate: AnyObject {
    func screenTimeoutDidOccur()
}

class ScreenTimeoutManager {
    static let shared = ScreenTimeoutManager()
    
    weak var delegate: ScreenTimeoutDelegate?
    
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
            selector: #selector(resetTimer),
            name: UIDevice.proximityStateDidChangeNotification,
            object: nil
        )
    }
    
    func startTracking(duration: TimeInterval? = nil, delegate: ScreenTimeoutDelegate? = nil) {
        guard !isTracking else { return }
        
        if let duration = duration {
            timeoutDuration = max(30, min(duration, 1800))
        }
        
        self.delegate = delegate
        
        startInactivityTimer()
        startBackgroundTimer()
        
        isTracking = true
        UIApplication.shared.isIdleTimerDisabled = true
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
        
        let state = UIApplication.shared.applicationState
        switch state {
        case .background, .inactive:
            handleInactivity()
        case .active:
            resetTimer()
        @unknown default:
            break
        }
    }
    
    private func handleInactivity() {
        DispatchQueue.main.async { [weak self] in
            UIApplication.shared.isIdleTimerDisabled = false
            self?.delegate?.screenTimeoutDidOccur()
        }
        
        stopTracking()
    }
    
    @objc private func resetTimer() {
        startInactivityTimer()
    }
    
    func stopTracking() {
        guard isTracking else { return }
        
        inactivityTimer?.invalidate()
        backgroundTimer?.invalidate()
        isTracking = false
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    deinit {
        stopTracking()
        NotificationCenter.default.removeObserver(self)
    }
}

class ExampleViewController: UIViewController, ScreenTimeoutDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ScreenTimeoutManager.shared.startTracking(
            duration: 120,
            delegate: self
        )
    }
    
    func screenTimeoutDidOccur() {
        let alertController = UIAlertController(
            title: "Увага",
            message: "Час очікування вичерпано",
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(
            title: "ОК",
            style: .default
        ) { [weak self] _ in
            self?.dismiss(animated: true)
        }
        
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
}
