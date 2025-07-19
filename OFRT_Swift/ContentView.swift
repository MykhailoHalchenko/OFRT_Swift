import SwiftUI

class ContentViewModel: ObservableObject {
    @Published var isTracking = false
    @Published var remainingTime: TimeInterval = 120
    @Published var showTimeoutAlert = false
    private var countdownTimer: Timer?
    
    init() {
        setupNotifications()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            forName: .screenTimeoutDidOccur,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleTimeout()
        }
    }
    
    func startTracking() {
        guard !isTracking else { return }
        ScreenTimeoutManager.shared.startTracking(duration: remainingTime)
        isTracking = true
        countdownTimer?.invalidate()
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.remainingTime = max(0, self.remainingTime - 1)
            if self.remainingTime == 0 {
                self.countdownTimer?.invalidate()
            }
        }
    }
    
    func stopTracking() {
        ScreenTimeoutManager.shared.stopTracking()
        countdownTimer?.invalidate()
        isTracking = false
        remainingTime = 120
    }
    
    private func handleTimeout() {
        DispatchQueue.main.async { [weak self] in
            self?.isTracking = false
            self?.remainingTime = 120
            self?.countdownTimer?.invalidate()
            self?.showTimeoutAlert = true
        }
    }
    
    func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            Text(LocalizationManager.ScreenTimeout.title())
                .font(.title)
                .fontWeight(.bold)
            
            Text(viewModel.timeString(from: viewModel.remainingTime))
                .font(.largeTitle)
                .monospacedDigit()
            
            HStack {
                Button(action: viewModel.startTracking) {
                    Text("Start Tracking")
                        .padding()
                        .background(viewModel.isTracking ? Color.gray : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(viewModel.isTracking)
                
                Button(action: viewModel.stopTracking) {
                    Text("Stop Tracking")
                        .padding()
                        .background(viewModel.isTracking ? Color.red : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(!viewModel.isTracking)
            }
        }
        .alert(isPresented: $viewModel.showTimeoutAlert) {
            Alert(
                title: Text(LocalizationManager.ScreenTimeout.title()),
                message: Text(LocalizationManager.ScreenTimeout.message()),
                dismissButton: .default(Text(LocalizationManager.ScreenTimeout.okButton()))
            )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
